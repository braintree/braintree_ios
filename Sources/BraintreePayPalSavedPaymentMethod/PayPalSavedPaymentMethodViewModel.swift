import Foundation
import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
@_spi(BraintreePayPalSavedPaymentMethod) import BraintreePayPal
#endif

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
        /// The FI could not be fetched (e.g. a network failure), so only PayPal is identified.
        case brandOnly
        /// PayPal has neither an FI nor an email for the buyer, so there is nothing to show.
        case hidden
    }

    // MARK: - Internal Properties

    /// What the FI region currently shows.
    @Published private(set) var fiState: FIState

    /// Whether the in-app "Learn more" lander sheet is showing.
    @Published var isLanderPresented = false

    /// Whether the full-screen loader is showing (create-payment-resource in flight).
    @Published private(set) var isEditing = false

    /// The composed credit (Pay Later) message to render, or `nil` to hide the row.
    @Published private(set) var creditMessage: CreditMessageContent?

    /// Set once an edit returns a nonce.
    @Published private(set) var didCompleteEdit = false

    /// Exposed for testing to inject a fake application.
    var application: URLOpener = UIApplication.shared

    /// The "Learn more" lander URL of the current credit message.
    var learnMoreURL: URL? {
        creditMessage?.learnMore?.url
    }

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
        case .brandOnly, .hidden:
            return false
        }
    }

    // MARK: - Private Properties

    /// The merchant's callback for the edit result.
    private let completion: (BTPayPalAccountNonce?, Error?) -> Void

    /// `nil` for previews, which seed `fiState` directly instead of fetching.
    private let fetchClient: PayPalSavedPaymentMethodClient?

    /// Held until the loader is off screen: iOS drops a modal presented over one still showing.
    private var pendingEditResult: (nonce: BTPayPalAccountNonce?, error: Error?)?

    /// Set when the loader is requested, so a result that lands while it animates in still waits for it.
    private var isEditLoaderShowing = false

    /// Only the latest credit fetch may set `creditMessage`, so an older amount's response can't land last.
    private var creditTask: Task<Void, Never>?

    // MARK: - Initializers

    /// Creates a view model that fetches through `fetchClient`.
    init(
        fetchClient: PayPalSavedPaymentMethodClient?,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void = { _, _ in }
    ) {
        self.fetchClient = fetchClient
        self.completion = completion
        self.fiState = .loading
    }

    /// Creates a view model backed by a `PayPalSavedPaymentMethodClient` for the given client token.
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
    convenience init(previewState: FIState, creditMessage: CreditMessageContent? = nil) {
        self.init(fetchClient: nil)
        self.fiState = previewState
        self.creditMessage = creditMessage
    }

    // MARK: - Internal Methods

    /// The requests are passed in per call rather than stored: `@StateObject` builds this view model
    /// once, so anything captured here would go stale when the merchant updates the amount.
    func onAppear(request: PayPalSavedPaymentMethodRequest, showCreditMessaging: Bool) {
        // `onAppear` refires on tab switches and navigation pop-backs. Refetching then would
        // replace the post-edit instrument with the pre-edit one the API still returns.
        guard !didCompleteEdit else { return }

        Task { [weak self] in await self?.loadBuyerDefaultBillingAgreement(request: request) }

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
    /// payer (email); else the component hides entirely (a network failure keeps the brand mark
    /// via the `loadBuyerDefaultBillingAgreement` catch instead).
    static func state(from summary: PayPalSavedPaymentMethodSummary) -> FIState {
        if let instrument = summary.paymentMethods.first {
            return .instrument(instrument)
        }
        if let payer = summary.payer, let email = payer.email {
            // PayPal omits `editable` rather than sending false, so an absent flag must not surface a
            // pencil we cannot confirm the buyer is allowed to use.
            return .displayOnly(email: email, isEditable: payer.isEditable ?? false)
        }
        return .hidden
    }

    /// Starts the edit flow; taps while an edit is already in flight are ignored.
    func editTapped(
        checkoutRequest: BTPayPalCheckoutRequest,
        request: PayPalSavedPaymentMethodRequest
    ) {
        guard !isEditing else { return }
        // TODO: emit the edit tapped analytics event once the catalog is approved.
        isEditing = true
        isEditLoaderShowing = true
        Task { [weak self] in await self?.performEdit(checkoutRequest: checkoutRequest, request: request) }
    }

    /// An abandoned app switch produces no callback — `BTPayPalClient` leaves its continuation
    /// suspended — so foregrounding is the only signal that the buyer is back. Matches `PayPalButton`.
    func appReturnedToForeground() {
        isEditing = false
    }

    /// Called when the full-screen edit loader appears; covers a retap while the previous one is dismissing.
    func editLoaderDidAppear() {
        isEditLoaderShowing = true
    }

    /// Called when the full-screen edit loader is dismissed; delivers any result held for it.
    func editLoaderDidDismiss() {
        isEditLoaderShowing = false
        guard let result = pendingEditResult else { return }
        pendingEditResult = nil
        completion(result.nonce, result.error)
    }

    /// Opens the "Learn more" lander in-app when PayPal allows embedding, otherwise in the browser.
    func learnMoreTapped() {
        // TODO: emit the learn more tapped analytics event once the catalog is approved.
        guard let learnMore = creditMessage?.learnMore else { return }

        if learnMore.isEmbeddable {
            isLanderPresented = true
        } else {
            application.open(learnMore.url, options: [:], completionHandler: nil)
        }
    }

    // MARK: - Private Methods

    /// Resolves the funding instrument on the buyer's default billing agreement (the one PayPal charges unless they
    /// change it) and maps it to `fiState`. Any failure falls back to the brand-only tile so checkout is never blocked.
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

    /// Fetches the Pay Later message. Additive — any failure hides the row.
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
            content = nil
        }

        guard !Task.isCancelled, !didCompleteEdit else { return }
        creditMessage = content
    }

    /// Runs the edit, then the cosmetic FI refresh. The full-screen loader is held until the nonce
    /// arrives; the FI then shimmers until the refresh settles. The merchant only receives
    /// `(nonce, error)` — a refresh failure after a successful edit hides the row, since the
    /// pre-edit instrument is no longer the one that will be charged.
    private func performEdit(
        checkoutRequest: BTPayPalCheckoutRequest,
        request: PayPalSavedPaymentMethodRequest
    ) async {
        guard let fetchClient else {
            isEditing = false
            return
        }

        let nonce: BTPayPalAccountNonce
        do {
            nonce = try await fetchClient.editFundingInstrument(request: checkoutRequest)
        } catch {
            finishEdit(nonce: nil, error: error)
            return
        }

        // The Pay Later offer is tied to the pre-edit funding instrument, so it stops applying once the buyer edits.
        didCompleteEdit = true
        creditMessage = nil
        finishEdit(nonce: nonce, error: nil)

        guard let orderID = nonce.paymentID else {
            fiState = .hidden
            return
        }

        fiState = .loading

        do {
            let summary = try await fetchClient.fetchPaymentMethod(
                fundingInstrumentType: .buyerUpdatedBillingAgreement,
                orderID: orderID,
                merchantAccountID: request.merchantAccountID
            )
            fiState = Self.state(from: summary)
        } catch {
            fiState = .hidden
        }
    }

    /// Delivers now if the loader is already gone (the app-switch rail clears it on foreground).
    private func finishEdit(nonce: BTPayPalAccountNonce?, error: Error?) {
        isEditing = false
        if isEditLoaderShowing {
            pendingEditResult = (nonce, error)
        } else {
            completion(nonce, error)
        }
    }
}
