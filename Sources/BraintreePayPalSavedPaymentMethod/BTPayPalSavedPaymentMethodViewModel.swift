import Foundation
import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
@_spi(BraintreePayPalSavedPaymentMethod) import BraintreePayPal
#endif

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
        case instrument(BTPayPalSavedPaymentMethod)
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

    /// The "Learn more" lander URL, populated from the credit-messaging response.
    private(set) var learnMoreURL: URL?

    // MARK: - Private Properties

    private let completion: (BTPayPalAccountNonce?, Error?) -> Void
    private let fetchClient: BTPayPalSavedPaymentMethodClient?
    private let urlOpener: URLOpener

    /// The FI shown before an edit began, restored if the cosmetic refresh is unavailable.
    private var fiStateBeforeEdit: FIState?

    // MARK: - Initializers

    /// `fetchClient` is `nil` for previews, which seed `fiState` directly instead of fetching.
    init(
        fetchClient: BTPayPalSavedPaymentMethodClient?,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void = { _, _ in },
        urlOpener: URLOpener? = nil
    ) {
        self.fetchClient = fetchClient
        self.completion = completion
        self.urlOpener = urlOpener ?? UIApplication.shared
        self.fiState = .loading
    }

    convenience init(
        universalLink: URL,
        fallbackURLScheme: String?,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void,
        authorization: String,
        urlOpener: URLOpener? = nil
    ) {
        self.init(
            fetchClient: BTPayPalSavedPaymentMethodClient(
                authorization: authorization,
                universalLink: universalLink,
                fallbackURLScheme: fallbackURLScheme
            ),
            completion: completion,
            urlOpener: urlOpener
        )
    }

    /// Seeds a concrete state directly. Used by SwiftUI previews and unit tests to exercise
    /// each visual state without the fetch API.
    convenience init(previewState: FIState, showCreditMessage: Bool = false) {
        self.init(fetchClient: nil)
        self.fiState = previewState

        if showCreditMessage {
            let sample = CreditMessageContent(
                message: "Or 4 interest-free payments of $324.50.",
                learnMoreText: "Learn more",
                learnMoreURL: nil,
                isEmbeddable: false
            )
            self.creditMessage = sample
            self.learnMoreURL = sample.learnMoreURL
        }
    }

    // MARK: - Internal Methods

    /// The requests are passed in per call rather than stored: `@StateObject` builds this view model
    /// once, so anything captured here would go stale when the merchant updates the amount.
    func onAppear(request: BTPayPalSavedPaymentMethodRequest, showCreditMessaging: Bool) {
        Task { await loadStickyFI(request: request) }

        if showCreditMessaging {
            Task { await loadCreditMessaging(request: request) }
        }
    }

    func requestChanged(_ request: BTPayPalSavedPaymentMethodRequest, showCreditMessaging: Bool) {
        guard showCreditMessaging, !didCompleteEdit else { return }
        Task { await loadCreditMessaging(request: request) }
    }

    /// Resolves the sticky FI (`STICKY_FI`, JWT from the client token) and maps it to `fiState`.
    /// Any failure falls back to the brand-only tile so checkout is never blocked.
    private func loadStickyFI(request: BTPayPalSavedPaymentMethodRequest) async {
        guard let fetchClient else { return } // preview: state is pre-seeded
        do {
            let summary = try await fetchClient.fetchPaymentMethod(
                fundingInstrumentType: .stickyFI,
                merchantAccountID: request.merchantAccountID
            )
            fiState = Self.state(from: summary)
        } catch {
            fiState = .brandOnly
        }
    }

    /// Maps a fetched summary into a render state. Funding instrument wins; else the display-only
    /// payer (email); else the component hides entirely (a network failure keeps the brand mark
    /// via the `loadStickyFI` catch instead).
    static func state(from summary: BTPayPalSavedPaymentMethodSummary) -> FIState {
        if let instrument = summary.paymentMethods.first {
            return .instrument(instrument)
        }
        if let payer = summary.payer, let email = payer.email {
            return .displayOnly(email: email, isEditable: payer.isEditable)
        }
        return .hidden
    }

    /// Fetches the Pay Later message. Additive — any failure hides the row.
    private func loadCreditMessaging(request: BTPayPalSavedPaymentMethodRequest) async {
        guard let fetchClient else { return }
        do {
            let result = try await fetchClient.fetchCreditPresentmentMessages(
                amount: request.amount,
                currencyCode: request.currencyCode
            )
            creditMessage = CreditMessageContent(result: result)
            learnMoreURL = creditMessage?.learnMoreURL
        } catch {
            creditMessage = nil
        }
    }

    func editTapped(
        checkoutRequest: BTPayPalCheckoutRequest,
        request: BTPayPalSavedPaymentMethodRequest
    ) {
        guard !isEditing else { return }
        fiStateBeforeEdit = fiState
        isEditing = true
        Task { await performEdit(checkoutRequest: checkoutRequest, request: request) }
    }

    /// An abandoned app switch produces no callback — `BTPayPalClient` leaves its continuation
    /// suspended — so foregrounding is the only signal that the buyer is back. Matches `PayPalButton`.
    func appReturnedToForeground() {
        guard isEditing else { return }
        isEditing = false
        if let prior = fiStateBeforeEdit {
            fiState = prior
        }
        fiStateBeforeEdit = nil
    }

    /// Runs the edit, then the cosmetic FI refresh. The full-screen loader is held until the nonce
    /// arrives; the FI then shimmers until the refresh settles. The merchant only receives
    /// `(nonce, error)` — a refresh failure keeps the last-known FI, since the edit itself succeeded.
    private func performEdit(
        checkoutRequest: BTPayPalCheckoutRequest,
        request: BTPayPalSavedPaymentMethodRequest
    ) async {
        // Every exit path either replaced fiState or must restore what was on screen before the edit.
        var restoresPriorState = true
        defer {
            if restoresPriorState, let prior = fiStateBeforeEdit {
                fiState = prior
            }
            fiStateBeforeEdit = nil
            isEditing = false
        }

        guard let fetchClient else { return }

        let nonce: BTPayPalAccountNonce
        do {
            nonce = try await fetchClient.editFundingInstrument(request: checkoutRequest)
        } catch {
            completion(nil, error)
            return
        }

        isEditing = false
        // The Pay Later offer is tied to the pre-edit funding instrument, so it stops applying once the buyer edits.
        didCompleteEdit = true
        creditMessage = nil
        completion(nonce, nil)

        guard let orderID = nonce.paymentID else { return }

        fiState = .loading

        do {
            let summary = try await fetchClient.fetchPaymentMethod(
                fundingInstrumentType: .fiFromApprovedCheckout,
                orderID: orderID,
                merchantAccountID: request.merchantAccountID
            )
            fiState = Self.state(from: summary)
            restoresPriorState = false
        } catch {
            // Cosmetic refresh only — the defer restores the pre-edit FI.
        }
    }

    func learnMoreTapped() {
        // SFSafariViewController only loads web URLs, and PayPal marks landers it forbids embedding.
        guard let url = learnMoreURL, url.scheme == "https" || url.scheme == "http" else { return }

        if creditMessage?.isEmbeddable == true {
            isLanderPresented = true
        } else {
            urlOpener.open(url, options: [:], completionHandler: nil)
        }
    }
}
