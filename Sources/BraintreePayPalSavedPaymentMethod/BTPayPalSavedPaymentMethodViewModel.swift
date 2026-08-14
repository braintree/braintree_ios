import BraintreeCore
import BraintreePayPal
import Foundation

/// View model backing `BTPayPalSavedPaymentMethodView`.
///
/// Owns the FI load state and the "Learn more" lander presentation, and is the single
/// seam where the fetch/edit APIs plug in later. Today the networking calls are stubbed
/// (`onAppear` / `editTapped`) so the component is pure UI; every visual state is still
/// reachable via the internal preview initializer.
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
        /// No instrument, but the buyer email is known — show the email with the edit affordance.
        case displayOnly(email: String)
        /// FI unavailable (e.g. no network) — hide the FI text but keep the PayPal brand mark.
        case brandOnly
        /// No FI and no email — hide the component entirely.
        case hidden
    }

    // MARK: - Internal Properties

    @Published private(set) var fiState: FIState
    @Published var isLanderPresented = false

    let request: BTPayPalSavedPaymentMethodRequest
    let style: BTPayPalSavedPaymentMethodViewStyle

    /// The "Learn more" lander URL, populated from the credit-messaging response when the
    /// API is wired in. `nil` renders a placeholder in the lander.
    private(set) var learnMoreURL: URL?

    // MARK: - Private Properties

    private let onResult: (BTPayPalSavedPaymentMethodResult) -> Void
    private let apiClient: BTAPIClient?

    // MARK: - Initializers

    init(
        request: BTPayPalSavedPaymentMethodRequest,
        style: BTPayPalSavedPaymentMethodViewStyle,
        onResult: @escaping (BTPayPalSavedPaymentMethodResult) -> Void,
        apiClient: BTAPIClient?
    ) {
        self.request = request
        self.style = style
        self.onResult = onResult
        self.apiClient = apiClient
        self.fiState = .loading
    }

    /// Seeds a concrete state directly. Used by SwiftUI previews and unit tests to exercise
    /// each visual state without the fetch API.
    init(
        previewState: FIState,
        request: BTPayPalSavedPaymentMethodRequest,
        style: BTPayPalSavedPaymentMethodViewStyle = BTPayPalSavedPaymentMethodViewStyle()
    ) {
        self.request = request
        self.style = style
        self.onResult = { _ in }
        self.apiClient = nil
        self.fiState = previewState
    }

    // MARK: - Internal Methods

    func onAppear() {
        apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.savedPayPalPaymentMethodPresented)
        if request.showCreditMessage, style.showCreditMessaging {
            apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.creditMessagingPresented)
        }

        // TODO: [API integration] Resolve the sticky FI for initial display.
        // Call `BTVaultedPaymentMethodClient(...).fetchStickyFI()` (STICKY_FI +
        // paymentMethodIdJwt extracted from the client token), then map the returned
        // BTPayPalSavedPaymentMethodFISummary into `fiState`:
        //   - instrument present            → .instrument(BTPayPalSavedPaymentMethodFISummary)
        //   - payer email only              → .displayOnly(email:)
        //   - no network                    → .brandOnly
        //   - no FI and no email / failure  → .hidden  (+ savedPayPalPaymentMethodFetchFailed)
        // Until then the component stays in `.loading` (skeleton) on-device; previews
        // seed concrete states.
    }

    func editTapped() {
        apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.savedPayPalPaymentMethodEditSelected)

        // TODO: [API integration] Launch the edit paysheet.
        // Build/forward `request.payPalRequest` (with app switch enabled) to
        // `BTPayPalClient`; the `edit_billing_agreement_jwt` is injected internally from
        // the client token. On return: tokenize (paypal_accounts) + refresh FI
        // (FI_FROM_APPROVED_CHECKOUT), then invoke `onResult` with `.success` /
        // `.cancel` / `.failure` and re-render `fiState`.
    }

    func learnMoreTapped() {
        apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.creditMessagingSelected)
        isLanderPresented = true
    }
}
