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

    /// `true` once a `post` call has actually suspended. Await `waitUntilPOSTSuspended()` rather than
    /// polling this directly.
    public private(set) var isPOSTSuspended = false

    private var suspendedPOSTGate: CheckedContinuation<Void, Never>?

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
    /// No-op when nothing is parked.
    public func resumePOST() {
        let gate = suspendedPOSTGate
        suspendedPOSTGate = nil
        isPOSTSuspended = false
        gate?.resume()
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
            await withCheckedContinuation { continuation in
                suspendedPOSTGate = continuation
                isPOSTSuspended = true
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
        buttonType: String? = nil,
        contextID: String? = nil,
        contextType: String? = nil,
        correlationID: String? = nil,
        didEnablePayPalAppSwitch: Bool? = nil,
        didPayPalServerAttemptAppSwitch: Bool? = nil,
        errorDescription: String? = nil,
        fundingSource: String? = nil,
        isConfigFromCache: Bool? = nil,
        isVaultRequest: Bool? = nil,
        linkType: LinkType? = nil,
        merchantExperiment: String? = nil,
        pageType: String? = nil,
        recurringBillingPlanType: String? = nil,
        shopperSessionID: String? = nil,
        shouldRequestBillingAgreement: Bool? = nil
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
