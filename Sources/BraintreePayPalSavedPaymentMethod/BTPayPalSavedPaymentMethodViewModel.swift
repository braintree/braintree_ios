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

    /// The composed credit (Pay Later) message to render, or `nil` to hide the row.
    @Published private(set) var creditMessage: CreditMessageContent?

    let request: BTPayPalSavedPaymentMethodRequest
    let style: BTPayPalSavedPaymentMethodViewStyle

    /// The "Learn more" lander URL, populated from the credit-messaging response.
    private(set) var learnMoreURL: URL?

    // MARK: - Private Properties

    private let onResult: (BTPayPalSavedPaymentMethodResult) -> Void
    private let fetchClient: BTPayPalSavedPaymentMethodClient?

    private var apiClient: BTAPIClient? { fetchClient?.apiClient }

    // MARK: - Initializers

    init(
        request: BTPayPalSavedPaymentMethodRequest,
        style: BTPayPalSavedPaymentMethodViewStyle,
        onResult: @escaping (BTPayPalSavedPaymentMethodResult) -> Void,
        authorization: String
    ) {
        self.request = request
        self.style = style
        self.onResult = onResult
        self.fetchClient = BTPayPalSavedPaymentMethodClient(authorization: authorization)
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
        self.fetchClient = nil
        self.fiState = previewState
    }

    // MARK: - Internal Methods

    func onAppear() {
        apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.savedPayPalPaymentMethodPresented)
        Task { await loadStickyFI() }

        if request.showCreditMessage, style.showCreditMessaging {
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
                merchantAccountID: request.payPalRequest.merchantAccountID
            )
            fiState = Self.state(from: summary)
        } catch {
            apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.savedPayPalPaymentMethodFetchFailed)
            fiState = .brandOnly
        }
    }

    /// Maps a fetched summary into a render state. Funding instrument wins; else the display-only
    /// payer (email); else brand-only.
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
        return .brandOnly
    }

    /// Fetches the Pay Later message. Additive — any failure hides the row.
    private func loadCreditMessaging() async {
        guard let fetchClient, let currencyCode = request.payPalRequest.currencyCode else { return }
        do {
            let result = try await fetchClient.fetchCreditPresentmentMessages(
                amount: request.payPalRequest.amount,
                currencyCode: currencyCode
            )
            creditMessage = CreditMessageContent(result: result)
            learnMoreURL = creditMessage?.learnMoreURL
        } catch {
            creditMessage = nil
        }
    }

    func editTapped() {
        apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.savedPayPalPaymentMethodEditSelected)

        // TODO: [edit flow] Forward `request.payPalRequest` (editBillingAgreement + app switch)
        // to `BTPayPalClient.tokenize`, then on return run tokenize + FI refresh
        // (FI_FROM_APPROVED_CHECKOUT + orderID) in parallel and invoke `onResult`.
        // Blocked on exposing the approved-checkout `orderID`/paymentToken from `BTPayPalClient`.
    }

    func learnMoreTapped() {
        apiClient?.sendAnalyticsEvent(BTPayPalSavedPaymentMethodAnalytics.creditMessagingSelected)
        isLanderPresented = true
    }
}
