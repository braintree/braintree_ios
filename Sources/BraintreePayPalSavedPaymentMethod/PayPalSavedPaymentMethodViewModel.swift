import Foundation
import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
@_spi(BraintreePayPalSavedPaymentMethod) import BraintreePayPal
#endif

// swiftlint:disable type_body_length file_length
/// View model backing `PayPalSavedPaymentMethodView`.
///
/// Owns the FI load state and the "Learn more" lander presentation, and drives the
/// fetch (buyer default billing agreement + credit messaging) and edit (`BTPayPalClient` tokenize) flows.
/// Every visual state is also reachable via the internal preview initializer.
@MainActor
final class PayPalSavedPaymentMethodViewModel: ObservableObject {

    /// What is known about the buyer's funding instrument (FI).
    enum FIState: Equatable {
        /// The FI fetch has not finished yet.
        case loading
        /// PayPal resolved the FI that will be charged.
        case instrument(PayPalSavedPaymentMethod)
        /// PayPal has no FI to show, but knows the buyer's email; `isEditable` says whether the buyer can change the FI.
        case displayOnly(email: String, isEditable: Bool)
        /// PayPal can't show an FI or an email (a failed fetch, an empty response, or a failed refresh after an
        /// edit), so only the PayPal brand mark is shown.
        case brandOnly
    }

    /// The merchant's `(nonce, error)` for an edit.
    private typealias EditResult = (nonce: BTPayPalAccountNonce?, error: Error?)

    /// An in-app "Learn more" lander.
    struct Lander: Identifiable, Equatable {

        let url: URL
        var id: URL { url }
    }

    /// Where the edit flow is, from the tap until the merchant receives the result.
    private enum EditPhase {
        /// No edit is running and the loader is off screen.
        case idle
        /// The loader has been requested but has not appeared yet.
        case loaderRequested
        /// The result arrived first; the loader stays up until it appears, or it would never report a dismissal.
        case resultBeforeLoader(EditResult)
        /// The loader is on screen while the edit runs.
        case loaderShowing
        /// The loader is being taken down; any result is delivered once it is dismissed.
        case loaderDismissing(EditResult?)
    }

    // MARK: - Internal Properties

    /// What the FI region currently shows.
    @Published private(set) var fiState: FIState

    /// The "Learn more" lander showing in-app, or `nil`. Holds its own URL so the sheet stays filled even if the
    /// credit message is cleared while it's open.
    @Published var presentedLander: Lander?

    /// Whether the full-screen loader should be showing.
    var isEditing: Bool {
        switch editPhase {
        case .loaderRequested, .resultBeforeLoader, .loaderShowing:
            return true
        case .idle, .loaderDismissing:
            return false
        }
    }

    /// The composed credit (Pay Later) message to render, or `nil` to hide the row.
    @Published private(set) var creditMessage: CreditMessageContent?

    /// Set once an edit returns a nonce.
    @Published private(set) var didCompleteEdit = false

    /// Exposed for testing to inject a fake application.
    var application: URLOpener = UIApplication.shared

    /// The Pay Later offer is quoted against the pre-edit funding instrument and is only actionable if the
    /// buyer can change it, so it tracks the FI region and stays hidden once an edit completes.
    /// Derived rather than latched: the two fetches race, and this is re-read on every render.
    var showsCreditMessaging: Bool {
        guard !didCompleteEdit else { return false }

        switch fiState {
        case .loading, .instrument:
            return true
        case .displayOnly(_, let isEditable):
            return isEditable
        case .brandOnly:
            return false
        }
    }

    /// The Pay Later message to show. Held until the FI settles, since the FI decides whether the row may show.
    var visibleCreditMessage: CreditMessageContent? {
        guard fiState != .loading, showsCreditMessaging else { return nil }
        return creditMessage
    }

    /// The latest buyer default billing agreement fetch. Exposed for testing.
    private(set) var fiFetchTask: Task<Void, Never>?

    /// Only the latest credit fetch may set `creditMessage`, so an older amount's response can't land last.
    /// Exposed for testing.
    private(set) var creditTask: Task<Void, Never>?

    /// The latest edit. Exposed for testing.
    private(set) var editTask: Task<Void, Never>?

    /// Only the latest post-edit refetch may set `fiState`, so an earlier edit's FI can't land last.
    /// Exposed for testing.
    private(set) var fiRefetchTask: Task<Void, Never>?

    // MARK: - Private Properties

    /// The merchant's callback for the edit result.
    private let completion: (BTPayPalAccountNonce?, Error?) -> Void

    /// `nil` for previews, which seed `fiState` directly instead of fetching.
    private let fetchClient: PayPalSavedPaymentMethodClient?

    /// Drives `isEditing` and holds the edit result until the loader is gone.
    @Published private var editPhase = EditPhase.idle

    /// The request `creditMessage` was quoted for.
    private var creditMessageRequest: PayPalSavedPaymentMethodRequest?

    /// The order approved by the last edit, sent as the `context_id` of the post-edit render.
    private var approvedOrderID: String?

    /// The instrument on screen, for analytics.
    private var instrument: PayPalSavedPaymentMethod? {
        guard case .instrument(let instrument) = fiState else { return nil }
        return instrument
    }

    // MARK: - Initializers

    /// Creates a view model that fetches through `fetchClient`.
    /// - Parameters:
    ///   - fetchClient: Runs the fetches and the edit. `nil` for previews, which seed `fiState` directly.
    ///   - completion: Receives the edit result: a nonce for the FI the buyer chose, or an error.
    init(
        fetchClient: PayPalSavedPaymentMethodClient?,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void = { _, _ in }
    ) {
        self.fetchClient = fetchClient
        self.completion = completion
        self.fiState = .loading
    }

    /// Creates a view model backed by a `PayPalSavedPaymentMethodClient` for the given client token.
    /// - Parameters:
    ///   - authorization: A client token. Tokenization keys can't fetch the FI or edit it.
    ///   - universalLink: The merchant's universal link, used to return from the PayPal app.
    ///   - fallbackURLScheme: The merchant's URL scheme, used if the universal link can't open the app.
    ///   - completion: Receives the edit result: a nonce for the FI the buyer chose, or an error.
    convenience init(
        authorization: String,
        universalLink: URL,
        fallbackURLScheme: String?,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        self.init(
            fetchClient: PayPalSavedPaymentMethodClient(
                authorization: authorization,
                universalLink: universalLink,
                fallbackURLScheme: fallbackURLScheme
            ),
            completion: completion
        )
    }

    /// Seeds a concrete state directly. Used by SwiftUI previews and unit tests to exercise
    /// each visual state without the fetch API.
    /// - Parameters:
    ///   - previewState: The FI state to show.
    ///   - creditMessage: The Pay Later message to show, or `nil` to hide the row.
    convenience init(previewState: FIState, creditMessage: CreditMessageContent? = nil) {
        self.init(fetchClient: nil)
        self.fiState = previewState
        self.creditMessage = creditMessage
    }

    // MARK: - Internal Methods

    /// Fetches the buyer's default FI and, when enabled, the Pay Later message. The request is passed per call
    /// rather than stored: `@StateObject` builds this view model once, so a stored copy would go stale.
    func onAppear(request: PayPalSavedPaymentMethodRequest, showCreditMessaging: Bool) {
        // `onAppear` refires on tab switches and navigation pop-backs. Refetching then would
        // replace the post-edit instrument with the pre-edit one the API still returns.
        guard !didCompleteEdit else { return }

        fiFetchTask = Task { [weak self] in await self?.loadBuyerDefaultBillingAgreement(request: request) }

        if showCreditMessaging {
            startCreditFetch(request: request)
        }
    }

    /// Refetches the Pay Later message when the merchant changes the amount or currency.
    func requestChanged(_ request: PayPalSavedPaymentMethodRequest, showCreditMessaging: Bool) {
        guard showCreditMessaging, !didCompleteEdit else { return }
        startCreditFetch(request: request)
    }

    /// Maps a fetched summary into a render state. Funding instrument wins; else the display-only
    /// payer (email); else only the PayPal brand mark.
    static func state(from summary: PayPalSavedPaymentMethodSummary) -> FIState {
        if let instrument = summary.paymentMethods.first {
            return .instrument(instrument)
        }
        if let payer = summary.payer, let email = payer.email {
            // PayPal omits `editable` rather than sending false, so an absent flag must not surface a
            // pencil we cannot confirm the buyer is allowed to use.
            return .displayOnly(email: email, isEditable: payer.isEditable ?? false)
        }
        return .brandOnly
    }

    /// Starts the edit flow; taps while an edit or its loader is still up are ignored.
    func editTapped(
        checkoutRequest: BTPayPalCheckoutRequest,
        request: PayPalSavedPaymentMethodRequest
    ) {
        guard case .idle = editPhase else { return }
        fetchClient?.apiClient.sendAnalyticsEvent(
            PayPalSavedPaymentMethodAnalytics.editSelected,
            fiBrand: instrument?.cardBrand,
            fiType: instrument?.type?.rawValue
        )
        editPhase = .loaderRequested
        editTask = Task { [weak self] in await self?.performEdit(checkoutRequest: checkoutRequest, request: request) }
    }

    /// An abandoned app switch produces no callback — `BTPayPalClient` leaves its continuation
    /// suspended — so foregrounding is the only signal that the buyer is back. Matches `PayPalButton`.
    func appReturnedToForeground() {
        switch editPhase {
        case .loaderRequested:
            editPhase = .idle
        case .resultBeforeLoader(let result):
            editPhase = .idle
            completion(result.nonce, result.error)
        case .loaderShowing:
            editPhase = .loaderDismissing(nil)
        case .idle, .loaderDismissing:
            break
        }
    }

    /// Called when the full-screen edit loader appears. Takes it down if a result already arrived.
    func editLoaderDidAppear() {
        switch editPhase {
        case .loaderRequested:
            editPhase = .loaderShowing
        case .resultBeforeLoader(let result):
            editPhase = .loaderDismissing(result)
        case .idle:
            // Presented after a foreground already cleared it, so new taps wait for its dismissal.
            editPhase = .loaderDismissing(nil)
        case .loaderShowing, .loaderDismissing:
            break
        }
    }

    /// Called when the full-screen edit loader is dismissed; delivers any result held for it.
    func editLoaderDidDismiss() {
        let phase = editPhase
        editPhase = .idle
        switch phase {
        case .resultBeforeLoader(let result), .loaderDismissing(.some(let result)):
            completion(result.nonce, result.error)
        case .idle, .loaderRequested, .loaderShowing, .loaderDismissing(nil):
            break
        }
    }

    /// Opens the "Learn more" lander in-app when PayPal allows embedding, otherwise in the browser.
    func learnMoreTapped() {
        guard let learnMore = creditMessage?.learnMore else { return }
        fetchClient?.apiClient.sendAnalyticsEvent(
            PayPalSavedPaymentMethodAnalytics.creditMessagingLearnMoreSelected,
            messageType: creditMessage?.messageType
        )

        if learnMore.isEmbeddable {
            presentedLander = Lander(url: learnMore.url)
        } else {
            application.open(learnMore.url, options: [:], completionHandler: nil)
        }
    }

    /// Called when `fiState` changes on screen. Reports the settled state as a render; the skeleton is not one.
    func fiDidRender(style: PayPalSavedPaymentMethodViewStyle) {
        let shownContent: String
        let renderedEditTag: Bool

        switch fiState {
        case .loading:
            return
        case .instrument:
            (shownContent, renderedEditTag) = ("funding_instrument", true)
        case .displayOnly(_, let isEditable):
            (shownContent, renderedEditTag) = ("email_only", isEditable)
        case .brandOnly:
            shownContent = style.showPayPalLogo || style.showPayPalLabel ? "brand_only" : "hidden"
            renderedEditTag = false
        }

        fetchClient?.apiClient.sendAnalyticsEvent(
            PayPalSavedPaymentMethodAnalytics.renderSucceeded,
            contextID: approvedOrderID,
            fiBrand: instrument?.cardBrand,
            fiID: instrument?.id,
            fiType: instrument?.type?.rawValue,
            renderedEditTag: renderedEditTag,
            renderedLabel: style.showPayPalLabel,
            renderedLogo: style.showPayPalLogo,
            renderedMessageSlot: style.showPayPalCreditMessaging && showsCreditMessaging,
            renderTrigger: didCompleteEdit ? "fi_from_approved_checkout" : "sticky_fi",
            shownContent: shownContent
        )
    }

    /// Called when `visibleCreditMessage` changes on screen. Reports a shown message as a render.
    func creditMessageDidRender() {
        guard let visibleCreditMessage else { return }

        fetchClient?.apiClient.sendAnalyticsEvent(
            PayPalSavedPaymentMethodAnalytics.creditMessagingRenderSucceeded,
            messageType: visibleCreditMessage.messageType
        )
    }

    // MARK: - Private Methods

    /// Resolves the funding instrument on the buyer's default billing agreement (the one PayPal charges unless they
    /// change it) and maps it to `fiState`. A failed first fetch falls back to the brand-only tile so checkout is
    /// never blocked; a failed refetch on re-appear keeps what is already shown.
    private func loadBuyerDefaultBillingAgreement(request: PayPalSavedPaymentMethodRequest) async {
        guard let fetchClient else { return } // preview: state is pre-seeded

        let state: FIState
        do {
            let summary = try await fetchClient.fetchPaymentMethod(
                fundingInstrumentType: .buyerDefaultBillingAgreement,
                merchantAccountID: request.merchantAccountID
            )
            state = Self.state(from: summary)
        } catch {
            guard fiState == .loading else { return }
            state = .brandOnly
        }

        // An edit may have completed while this was in flight; the post-edit refetch owns `fiState` from then on.
        guard !didCompleteEdit else { return }
        fiState = state
    }

    /// Cancels any in-flight credit fetch and starts one for `request`.
    private func startCreditFetch(request: PayPalSavedPaymentMethodRequest) {
        creditTask?.cancel()
        creditTask = Task { [weak self] in await self?.loadCreditMessaging(request: request) }
    }

    /// Fetches the Pay Later message. Additive — a failure hides the row, except a failed refresh for the
    /// same request (e.g. on re-appear), which keeps the message already shown.
    private func loadCreditMessaging(request: PayPalSavedPaymentMethodRequest) async {
        guard let fetchClient else { return }

        let content: CreditMessageContent?
        do {
            let result = try await fetchClient.fetchCreditPresentmentMessages(
                amount: request.amount,
                currencyCode: request.currencyCode
            )
            content = CreditMessageContent(result: result)
        } catch {
            guard request != creditMessageRequest else { return }
            content = nil
        }

        guard !Task.isCancelled, !didCompleteEdit else { return }
        creditMessage = content
        creditMessageRequest = request
    }

    /// Runs the edit, hands the result to `finishEdit`, then refreshes the FI for the approved order. The FI
    /// shimmers until the refresh settles. The merchant only receives `(nonce, error)`.
    private func performEdit(
        checkoutRequest: BTPayPalCheckoutRequest,
        request: PayPalSavedPaymentMethodRequest
    ) async {
        guard let fetchClient else {
            editPhase = .idle
            return
        }

        let nonce: BTPayPalAccountNonce
        do {
            nonce = try await fetchClient.editFundingInstrument(request: checkoutRequest)
        } catch {
            finishEdit(nonce: nil, error: error)
            return
        }

        didCompleteEdit = true
        creditMessage = nil
        finishEdit(nonce: nonce, error: nil)

        fiRefetchTask?.cancel()
        approvedOrderID = nonce.paymentID
        guard let orderID = nonce.paymentID else {
            fiState = .brandOnly
            return
        }

        fiState = .loading
        fiRefetchTask = Task { [weak self] in
            await self?.loadBuyerUpdatedBillingAgreement(orderID: orderID, request: request)
        }
    }

    /// Resolves the FI the buyer picked for `orderID`. A failure shows only the brand mark, since the pre-edit
    /// instrument is no longer the one that will be charged.
    private func loadBuyerUpdatedBillingAgreement(orderID: String, request: PayPalSavedPaymentMethodRequest) async {
        guard let fetchClient else { return }

        let state: FIState
        do {
            let summary = try await fetchClient.fetchPaymentMethod(
                fundingInstrumentType: .buyerUpdatedBillingAgreement,
                orderID: orderID,
                merchantAccountID: request.merchantAccountID
            )
            state = Self.state(from: summary)
        } catch {
            state = .brandOnly
        }

        guard !Task.isCancelled else { return }
        fiState = state
    }

    /// Delivers now if the loader is gone, otherwise holds it until dismissal: iOS drops a modal shown over another.
    private func finishEdit(nonce: BTPayPalAccountNonce?, error: Error?) {
        switch editPhase {
        case .idle:
            completion(nonce, error)
        case .loaderRequested, .resultBeforeLoader:
            editPhase = .resultBeforeLoader((nonce, error))
        case .loaderShowing, .loaderDismissing:
            editPhase = .loaderDismissing((nonce, error))
        }
    }
}
