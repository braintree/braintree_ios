import BraintreeCore
import BraintreePayPal
import Foundation

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

    /// Whether the full-screen "Sending you to PayPal" loader is showing (create-payment-resource in flight).
    @Published private(set) var isEditing = false

    /// The composed credit (Pay Later) message to render, or `nil` to hide the row.
    @Published private(set) var creditMessage: CreditMessageContent?

    let checkoutRequest: BTPayPalCheckoutRequest
    let style: BTPayPalSavedPaymentMethodViewStyle

    /// The "Learn more" lander URL, populated from the credit-messaging response.
    private(set) var learnMoreURL: URL?

    // MARK: - Private Properties

    private let completion: (BTPayPalAccountNonce?, Error?) -> Void
    private let authorization: String
    private let universalLink: URL
    private let fallbackURLScheme: String?
    private let fetchClient: BTPayPalSavedPaymentMethodClient?

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
        authorization: String
    ) {
        self.amount = amount
        self.currencyCode = currencyCode
        self.checkoutRequest = request
        self.style = style
        self.universalLink = universalLink
        self.fallbackURLScheme = fallbackURLScheme
        self.completion = completion
        self.authorization = authorization
        self.fetchClient = BTPayPalSavedPaymentMethodClient(authorization: authorization)
        self.fiState = .loading
    }

    /// Seeds a concrete state directly. Used by SwiftUI previews and unit tests to exercise
    /// each visual state without the fetch API.
    init(
        previewState: FIState,
        request: BTPayPalCheckoutRequest,
        style: BTPayPalSavedPaymentMethodViewStyle = BTPayPalSavedPaymentMethodViewStyle()
    ) {
        self.amount = "0"
        self.currencyCode = "USD"
        self.checkoutRequest = request
        self.style = style
        // swiftlint:disable:next force_unwrapping
        self.universalLink = URL(string: "https://example.com")!
        self.fallbackURLScheme = nil
        self.completion = { _, _ in }
        self.authorization = ""
        self.fetchClient = nil
        self.fiState = previewState
    }

    // MARK: - Internal Methods

    func onAppear() {
        apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.savedPayPalPaymentMethodPresented)
        Task { await loadStickyFI() }

        if style.showCreditMessaging {
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

    /// Called when the app returns from the PayPal paysheet/app switch: dismiss the full-screen
    /// loader and show the FI shimmer while the cosmetic refresh (inside `editFundingInstrument`)
    /// finishes.
    func didReturnFromPayPal() {
        guard isEditing else { return }
        isEditing = false
        fiState = .loading
    }

    /// Delegates the edit + cosmetic FI refresh to the data layer. The merchant only receives
    /// `(nonce, error)`; the refreshed `summary` updates the displayed FI, and a refresh failure
    /// keeps the last-known FI (the edit itself still succeeded).
    private func performEdit() async {
        guard let fetchClient else {
            isEditing = false
            return
        }
        do {
            let result = try await fetchClient.editFundingInstrument(
                request: checkoutRequest,
                merchantAccountID: checkoutRequest.merchantAccountID
            )
            isEditing = false
            if let summary = result.summary {
                fiState = Self.state(from: summary)
            } else if let prior = fiStateBeforeEdit {
                fiState = prior
            }
            completion(result.nonce, nil)
        } catch {
            isEditing = false
            if let prior = fiStateBeforeEdit {
                fiState = prior
            }
            completion(nil, error)
        }
        fiStateBeforeEdit = nil
    }

    func learnMoreTapped() {
        apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.creditMessagingSelected)
        guard learnMoreURL != nil else { return }
        isLanderPresented = true
    }
}
