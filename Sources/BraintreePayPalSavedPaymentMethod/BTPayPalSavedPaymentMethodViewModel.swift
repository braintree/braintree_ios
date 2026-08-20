import BraintreeCore
@_spi(BraintreePayPalSavedPaymentMethod) import BraintreePayPal
import Foundation
import UIKit

/// View model backing `BTPayPalSavedPaymentMethodView`.
///
/// Owns the FI load state and the "Learn more" lander presentation, and drives the
/// fetch (sticky FI + credit messaging) and edit (`BTPayPalClient` tokenize) flows.
/// Every visual state is also reachable via the internal preview initializer.
@MainActor
final class BTPayPalSavedPaymentMethodViewModel: ObservableObject {

    /// The render state of the FI display region. Maps to the fallback matrix in the LLD
    /// (Error Handling & Fallback UI).
    enum FIState: Equatable {
        /// Fetch in flight — skeleton shimmer.
        case loading
        /// An instrument was resolved. A `nil` `imageURL` renders the generic fallback glyph;
        /// long labels ellipsize (truncation case).
        case instrument(BTPayPalSavedPaymentMethodFISummary)
        /// No instrument, but the buyer email is known — show the email; `isEditable` gates the pencil.
        case displayOnly(email: String, isEditable: Bool)
        /// FI unavailable (e.g. no network) — hide the FI text but keep the PayPal brand mark.
        case brandOnly
        /// No FI and no email — hide the component entirely.
        case hidden
    }

    // MARK: - Internal Properties

    @Published private(set) var fiState: FIState
    @Published var isLanderPresented = false

    /// Whether the full-screen loader is showing (create-payment-resource in flight).
    @Published private(set) var isEditing = false

    /// The composed credit (Pay Later) message to render, or `nil` to hide the row.
    @Published private(set) var creditMessage: CreditMessageContent?

    /// Set once an edit returns a nonce. The Pay Later offer was quoted against the pre-edit funding
    /// instrument, so the row stays hidden for the rest of the component's life.
    @Published private(set) var didCompleteEdit = false

    let checkoutRequest: BTPayPalCheckoutRequest
    let style: BTPayPalSavedPaymentMethodViewStyle

    /// The "Learn more" lander URL, populated from the credit-messaging response.
    private(set) var learnMoreURL: URL?

    // MARK: - Private Properties

    private let completion: (BTPayPalAccountNonce?, Error?) -> Void
    private let authorization: String
    private let fetchClient: BTPayPalSavedPaymentMethodClient?
    private let urlOpener: URLOpener

    /// The order amount + currency the credit (Pay Later) message is calculated from.
    private let amount: String
    private let currencyCode: String

    /// The FI shown before an edit began, restored if the cosmetic refresh is unavailable.
    private var fiStateBeforeEdit: FIState?

    private var apiClient: BTAPIClient? { fetchClient?.apiClient }

    // MARK: - Initializers

    init(
        amount: String,
        currencyCode: String = "USD",
        request: BTPayPalCheckoutRequest,
        style: BTPayPalSavedPaymentMethodViewStyle,
        universalLink: URL,
        fallbackURLScheme: String?,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void,
        authorization: String,
        urlOpener: URLOpener = UIApplication.shared
    ) {
        self.amount = amount
        self.currencyCode = currencyCode
        // The component opts into the billing-agreement edit itself; merchants never set it.
        request.enableEditBillingAgreement()
        self.checkoutRequest = request
        self.style = style
        self.completion = completion
        self.authorization = authorization
        self.urlOpener = urlOpener
        self.fetchClient = BTPayPalSavedPaymentMethodClient(
            authorization: authorization,
            universalLink: universalLink,
            fallbackURLScheme: fallbackURLScheme
        )
        self.fiState = .loading
    }

    /// Seeds a concrete state directly. Used by SwiftUI previews and unit tests to exercise
    /// each visual state without the fetch API.
    init(
        previewState: FIState,
        request: BTPayPalCheckoutRequest,
        style: BTPayPalSavedPaymentMethodViewStyle = BTPayPalSavedPaymentMethodViewStyle(),
        showCreditMessage: Bool = false
    ) {
        self.amount = "0"
        self.currencyCode = "USD"
        self.checkoutRequest = request
        self.style = style
        self.completion = { _, _ in }
        self.authorization = ""
        self.urlOpener = UIApplication.shared
        self.fetchClient = nil
        self.fiState = previewState

        if showCreditMessage {
            let sample: CreditMessageContent = CreditMessageContent(
                message: style.container?.creditMessaging?.messageText
                    ?? BTPayPalSavedPaymentMethodViewStyle.CreditMessagingStyle().messageText,
                learnMoreText: BTPayPalSavedPaymentMethodViewStyle.CreditMessagingStyle().learnMoreText,
                learnMoreURL: nil,
                isEmbeddable: false
            )
            self.creditMessage = sample
            self.learnMoreURL = sample.learnMoreURL
        }
    }

    // MARK: - Internal Methods

    func onAppear() {
        apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.savedPayPalPaymentMethodPresented)
        Task { await loadStickyFI() }

        if style.showPayPalCreditMessaging {
            apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.creditMessagingPresented)
            Task { await loadCreditMessaging() }
        }
    }

    /// Resolves the sticky FI (`STICKY_FI`, JWT from the client token) and maps it to `fiState`.
    /// Any failure falls back to the brand-only tile so checkout is never blocked.
    private func loadStickyFI() async {
        guard let fetchClient else { return } // preview: state is pre-seeded
        do {
            let summary = try await fetchClient.fetchPaymentMethod(
                fundingInstrumentType: .stickyFI,
                merchantAccountID: checkoutRequest.merchantAccountID
            )
            fiState = Self.state(from: summary)
        } catch {
            apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.savedPayPalPaymentMethodFetchFailed)
            fiState = .brandOnly
        }
    }

    /// Maps a fetched summary into a render state. Funding instrument wins; else the display-only
    /// payer (email); else the component hides entirely (a network failure keeps the brand mark
    /// via the `loadStickyFI` catch instead).
    static func state(from summary: BTPayPalSavedPaymentMethodSummary) -> FIState {
        if let fi = summary.paymentMethods.first {
            return .instrument(
                BTPayPalSavedPaymentMethodFISummary(
                    type: fi.type?.rawValue ?? "",
                    label: fi.label ?? "",
                    lastDigits: fi.lastDigits,
                    imageURL: fi.imageURL,
                    subtype: fi.subtype
                )
            )
        }
        if let payer = summary.payer, let email = payer.email {
            return .displayOnly(email: email, isEditable: payer.isEditable)
        }
        return .hidden
    }

    /// Fetches the Pay Later message. Additive — any failure hides the row.
    private func loadCreditMessaging() async {
        guard let fetchClient else { return }
        do {
            let result = try await fetchClient.fetchCreditPresentmentMessages(
                amount: amount,
                currencyCode: currencyCode
            )
            creditMessage = CreditMessageContent(result: result)
            learnMoreURL = creditMessage?.learnMoreURL
        } catch {
            apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.creditMessagingFailed)
            creditMessage = nil
        }
    }

    func editTapped() {
        guard !isEditing else { return }
        apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.savedPayPalPaymentMethodEditSelected)
        fiStateBeforeEdit = fiState
        isEditing = true
        Task { await performEdit() }
    }

    /// Runs the edit, then the cosmetic FI refresh. The full-screen loader is held until the nonce
    /// arrives; the FI then shimmers until the refresh settles. The merchant only receives
    /// `(nonce, error)` — a refresh failure keeps the last-known FI, since the edit itself succeeded.
    private func performEdit() async {
        guard let fetchClient else {
            isEditing = false
            return
        }

        let nonce: BTPayPalAccountNonce
        do {
            nonce = try await fetchClient.editFundingInstrument(request: checkoutRequest)
        } catch {
            isEditing = false
            if let prior = fiStateBeforeEdit {
                fiState = prior
            }
            fiStateBeforeEdit = nil
            completion(nil, error)
            return
        }

        isEditing = false
        // The Pay Later offer is tied to the pre-edit funding instrument, so it stops applying once the buyer edits.
        didCompleteEdit = true
        creditMessage = nil
        completion(nonce, nil)

        guard let orderID = nonce.paymentID else {
            if let prior = fiStateBeforeEdit {
                fiState = prior
            }
            fiStateBeforeEdit = nil
            return
        }

        fiState = .loading

        do {
            let summary = try await fetchClient.fetchPaymentMethod(
                fundingInstrumentType: .fiFromApprovedCheckout,
                orderID: orderID,
                merchantAccountID: checkoutRequest.merchantAccountID
            )
            fiState = Self.state(from: summary)
        } catch {
            if let prior = fiStateBeforeEdit {
                fiState = prior
            }
        }

        fiStateBeforeEdit = nil
    }

    func learnMoreTapped() {
        apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.creditMessagingSelected)
        // SFSafariViewController only loads web URLs, and PayPal marks landers it forbids embedding.
        guard let url = learnMoreURL, url.scheme == "https" || url.scheme == "http" else { return }

        if creditMessage?.isEmbeddable == true {
            isLanderPresented = true
        } else {
            urlOpener.open(url, options: [:], completionHandler: nil)
        }
    }
}
