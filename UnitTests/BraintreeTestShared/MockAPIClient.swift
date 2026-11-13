import Foundation
@testable import BraintreeCore

public class MockAPIClient: BTAPIClient {
    public var lastPOSTPath = ""
    public var lastPOSTParameters = [:] as [AnyHashable: Any]?
    public var lastPOSTAPIClientHTTPType: BTAPIClientHTTPService?
    public var lastPOSTAdditionalHeaders: [String: String]? = [:]

    public var lastGETPath = ""
    public var lastGETParameters = [:] as [String: Any]?
    public var lastGETAPIClientHTTPType: BTAPIClientHTTPService?

    public var postedAnalyticsEvents: [String] = []
    public var postedApplicationState: String? = nil
    public var postedAppSwitchURL: [String: String?] = [:]
    public var postedRecurringBillingPlanType: String? = nil
    public var postedButtonOrder: String? = nil
    public var postedButtonType: String? = nil
    public var postedShouldRequestBillingAgreement = false
    public var postedIsVaultRequest = false
    public var postedLinkType: LinkType? = nil
    public var postedMerchantExperiment: String? = nil
    public var postedPageType: String? = nil
    public var postedContextID: String? = nil
    public var postedShopperSessionID: String? = nil
    public var postedIsPayPalAppInstalled: Bool? = nil
    public var postedDidEnablePayPalAppSwitch: Bool? = nil
    public var postedDidPayPalServerAttemptAppSwitch: Bool? = nil
    public var postedErrorDescription: String? = nil
    public var postedContextType: String? = nil
    public var postedFundingSource: String? = nil
    public var postedButtonSessionID: String? = nil
    public var postedSavedMethodBrand: String? = nil
    public var postedSavedMethodID: String? = nil
    public var postedSavedMethodType: String? = nil
    public var postedIsEditFIFlow: Bool? = nil
    public var postedPresentmentMessageType: String? = nil
    public var postedRenderedEditTag: Bool? = nil
    public var postedRenderedLabel: Bool? = nil
    public var postedRenderedLogo: Bool? = nil
    public var postedRenderedMessageSlot: Bool? = nil
    public var postedRenderTrigger: String? = nil
    public var postedShownContent: String? = nil
    /// The tags of each analytics event, keyed by event name, for actions that send more than one event.
    public var postedAnalyticsEventTags: [String: PostedAnalyticsEventTags] = [:]

    /// The tags sent with one analytics event.
    public struct PostedAnalyticsEventTags {

        public let buttonSessionID: String?
        public let contextID: String?
        public let errorDescription: String?
        public let presentmentMessageType: String?
        public let renderedEditTag: Bool?
        public let renderedLabel: Bool?
        public let renderedLogo: Bool?
        public let renderedMessageSlot: Bool?
        public let renderTrigger: String?
        public let savedMethodBrand: String?
        public let savedMethodID: String?
        public let savedMethodType: String?
        public let shownContent: String?
    }
    
    @objc public var cannedConfigurationResponseBody : BTJSON? = nil
    @objc public var cannedConfigurationResponseError : NSError? = nil

    public var cannedResponseError : NSError? = nil
    public var cannedHTTPURLResponse : HTTPURLResponse? = nil
    public var cannedResponseBody : BTJSON? = nil
    var cannedMetadata : BTClientMetadata? = nil

    var fetchedPaymentMethods = false
    var fetchPaymentMethodsSorting = false

    /// When `true`, `post` suspends instead of returning, so a test can observe state while the request is
    /// still in flight. Release it with `resumePOST()`. Defaults to `false`, preserving the behavior
    /// existing tests rely on.
    public var shouldSuspendPOST = false

    /// `true` while a `post` call is parked. Await `waitUntilPOSTSuspended()` rather than polling directly.
    public private(set) var isPOSTSuspended = false

    private var shouldResumePOST = false

    /// Suspends until a `post` call has parked, so a test cannot race ahead of the suspension.
    ///
    /// Polls with `Task.sleep` rather than `Task.yield` so it releases its thread between checks: a
    /// busy-spin here would hold a cooperative-pool thread and add pressure to the shared thread pool,
    /// which other concurrency tests in this suite are already sensitive to. Bounded by `timeout` so a
    /// `post` that is never reached fails the waiting test instead of hanging the run.
    public func waitUntilPOSTSuspended(timeout: TimeInterval = 2) async {
        let deadline = Date().addingTimeInterval(timeout)

        while !isPOSTSuspended && Date() < deadline {
            try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
        }
    }

    /// Releases a `post` call parked by `shouldSuspendPOST`, simulating the response finally arriving.
    public func resumePOST() {
        shouldResumePOST = true
    }

    public override func get(
        _ path: String,
        parameters: Encodable?,
        httpType: BTAPIClientHTTPService
    ) async throws -> (BTJSON?, HTTPURLResponse?) {
        lastGETPath = path
        lastGETParameters = try? parameters?.toDictionary()
        lastGETAPIClientHTTPType = httpType
        
        if let error = cannedResponseError {
            throw error
        }
        return (cannedResponseBody, cannedHTTPURLResponse)
    }

    public override func post(
        _ path: String,
        parameters: Encodable? = nil,
        headers: [String: String]? = nil,
        httpType: BTAPIClientHTTPService = .gateway
    ) async throws -> (BTJSON?, HTTPURLResponse?) {
        lastPOSTPath = path
        lastPOSTParameters = try? parameters?.toDictionary()
        lastPOSTAPIClientHTTPType = httpType
        lastPOSTAdditionalHeaders = headers

        if shouldSuspendPOST {
            isPOSTSuspended = true
            defer { isPOSTSuspended = false }

            // `Task.sleep` throws `CancellationError` when the task is cancelled, so parking here behaves
            // like a real in-flight `URLSession.data(for:)` request rather than an uncancellable block.
            while !shouldResumePOST {
                try await Task.sleep(nanoseconds: 1_000_000) // 1ms
            }
        }

        if let error = cannedResponseError {
            throw error
        }

        return (cannedResponseBody, cannedHTTPURLResponse)
    }
    
    public override func fetchOrReturnRemoteConfiguration(_ completionBlock: @escaping (BTConfiguration?, Error?) -> Void) {
        guard let responseBody = cannedConfigurationResponseBody else {
            completionBlock(nil, cannedConfigurationResponseError)
            return
        }
        completionBlock(BTConfiguration(json: responseBody), cannedConfigurationResponseError)
    }
    
    public override func fetchOrReturnRemoteConfiguration() async throws -> BTConfiguration {
        guard let responseBody = cannedConfigurationResponseBody else {
            throw cannedConfigurationResponseError ?? NSError(domain: "com.example.error", code: -1, userInfo: nil)
        }
        return BTConfiguration(json: responseBody)
    }

    public override func sendAnalyticsEvent(
        _ eventName: String,
        applicationState: String? = nil,
        appSwitchURL: URL? = nil,
        buttonOrder: String? = nil,
        buttonSessionID: String? = nil,
        buttonType: String? = nil,
        contextID: String? = nil,
        contextType: String? = nil,
        correlationID: String? = nil,
        didEnablePayPalAppSwitch: Bool? = nil,
        didPayPalServerAttemptAppSwitch: Bool? = nil,
        errorDescription: String? = nil,
        fundingSource: String? = nil,
        isConfigFromCache: Bool? = nil,
        isEditFIFlow: Bool? = nil,
        isVaultRequest: Bool? = nil,
        linkType: LinkType? = nil,
        merchantExperiment: String? = nil,
        pageType: String? = nil,
        presentmentMessageType: String? = nil,
        recurringBillingPlanType: String? = nil,
        renderedEditTag: Bool? = nil,
        renderedLabel: Bool? = nil,
        renderedLogo: Bool? = nil,
        renderedMessageSlot: Bool? = nil,
        renderTrigger: String? = nil,
        savedMethodBrand: String? = nil,
        savedMethodID: String? = nil,
        savedMethodType: String? = nil,
        shopperSessionID: String? = nil,
        shouldRequestBillingAgreement: Bool? = nil,
        shownContent: String? = nil
    ) {
        postedApplicationState = applicationState
        postedRecurringBillingPlanType = recurringBillingPlanType
        postedButtonType = buttonType
        postedButtonOrder = buttonOrder
        postedPageType = pageType
        postedContextID = contextID
        postedLinkType = linkType
        postedShouldRequestBillingAgreement = shouldRequestBillingAgreement ?? false
        postedIsVaultRequest = isVaultRequest ?? false
        postedMerchantExperiment = merchantExperiment
        postedAppSwitchURL[eventName] = appSwitchURL?.absoluteString
        postedShopperSessionID = shopperSessionID
        postedDidEnablePayPalAppSwitch = didEnablePayPalAppSwitch
        postedDidPayPalServerAttemptAppSwitch = didPayPalServerAttemptAppSwitch
        postedErrorDescription = errorDescription
        postedContextType = contextType
        postedFundingSource = fundingSource
        postedButtonSessionID = buttonSessionID
        postedSavedMethodBrand = savedMethodBrand
        postedSavedMethodID = savedMethodID
        postedSavedMethodType = savedMethodType
        postedIsEditFIFlow = isEditFIFlow
        postedPresentmentMessageType = presentmentMessageType
        postedRenderedEditTag = renderedEditTag
        postedRenderedLabel = renderedLabel
        postedRenderedLogo = renderedLogo
        postedRenderedMessageSlot = renderedMessageSlot
        postedRenderTrigger = renderTrigger
        postedShownContent = shownContent
        postedAnalyticsEventTags[eventName] = PostedAnalyticsEventTags(
            buttonSessionID: buttonSessionID,
            contextID: contextID,
            errorDescription: errorDescription,
            presentmentMessageType: presentmentMessageType,
            renderedEditTag: renderedEditTag,
            renderedLabel: renderedLabel,
            renderedLogo: renderedLogo,
            renderedMessageSlot: renderedMessageSlot,
            renderTrigger: renderTrigger,
            savedMethodBrand: savedMethodBrand,
            savedMethodID: savedMethodID,
            savedMethodType: savedMethodType,
            shownContent: shownContent
        )
        
        postedAnalyticsEvents.append(eventName)
    }

    func didFetchPaymentMethods(sorted: Bool) -> Bool {
        return fetchedPaymentMethods && fetchPaymentMethodsSorting == sorted
    }

    public override var metadata: BTClientMetadata {
        get {
            if let cannedMetadata = cannedMetadata {
                return cannedMetadata
            } else {
                cannedMetadata = BTClientMetadata()
                return cannedMetadata!
            }
        }
    }
}
