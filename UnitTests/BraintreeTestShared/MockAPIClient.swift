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
    public var postedButtonOrder: String? = nil
    public var postedButtonType: String? = nil
    public var postedIsVaultRequest = false
    public var postedLinkType: LinkType? = nil
    public var postedMerchantExperiment: String? = nil
    public var postedMerchantPassedUserAction: String? = nil
    public var postedPageType: String? = nil
    public var postedContextID: String? = nil
    public var postedShopperSessionID: String? = nil
    public var postedIsPayPalAppInstalled: Bool? = nil
    public var postedDidEnablePayPalAppSwitch: Bool? = nil
    public var postedDidPayPalServerAttemptAppSwitch: Bool? = nil
    public var postedErrorDescription: String? = nil
    public var postedContextType: String? = nil
    
    @objc public var cannedConfigurationResponseBody : BTJSON? = nil
    @objc public var cannedConfigurationResponseError : NSError? = nil

    public var cannedResponseError : NSError? = nil
    public var cannedHTTPURLResponse : HTTPURLResponse? = nil
    public var cannedResponseBody : BTJSON? = nil
    var cannedMetadata : BTClientMetadata? = nil

    var fetchedPaymentMethods = false
    var fetchPaymentMethodsSorting = false

    public override func get(_ path: String, parameters: Encodable?, httpType: BTAPIClientHTTPService, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        lastGETPath = path
        lastGETParameters = try? parameters?.toDictionary()
        lastGETAPIClientHTTPType = httpType
        
        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(cannedResponseBody, cannedHTTPURLResponse, cannedResponseError)
    }
    
    public override func post(_ path: String, parameters: [String: Any]?, httpType: BTAPIClientHTTPService, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        lastPOSTPath = path
        lastPOSTParameters = parameters
        lastPOSTAPIClientHTTPType = httpType
        
        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(cannedResponseBody, cannedHTTPURLResponse, cannedResponseError)
    }
    
    public override func post(_ path: String, parameters: Encodable, headers: [String: String]? = nil, httpType: BTAPIClientHTTPService = .gateway, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        lastPOSTPath = path
        lastPOSTParameters = try? parameters.toDictionary()
        lastPOSTAPIClientHTTPType = httpType
        lastPOSTAdditionalHeaders = headers
        
        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(cannedResponseBody, cannedHTTPURLResponse, cannedResponseError)
    }
    
    public override func fetchOrReturnRemoteConfiguration(_ completionBlock: @escaping (BTConfiguration?, Error?) -> Void) {
        guard let responseBody = cannedConfigurationResponseBody else {
            completionBlock(nil, cannedConfigurationResponseError)
            return
        }
        completionBlock(BTConfiguration(json: responseBody), cannedConfigurationResponseError)
    }
    
    public override func fetchConfiguration() async throws -> BTConfiguration {
        guard let responseBody = cannedConfigurationResponseBody else {
            throw cannedConfigurationResponseError ?? NSError(domain: "com.example.error", code: -1, userInfo: nil)
        }
        return BTConfiguration(json: responseBody)
    }

    public override func fetchPaymentMethodNonces(_ completion: @escaping ([BTPaymentMethodNonce]?, Error?) -> Void) {
        fetchedPaymentMethods = true
        fetchPaymentMethodsSorting = false
        completion([], nil)
    }
    
    public override func fetchPaymentMethodNonces(_ defaultFirst: Bool, completion: @escaping ([BTPaymentMethodNonce]?, Error?) -> Void) {
        fetchedPaymentMethods = true
        fetchPaymentMethodsSorting = false
        completion([], nil)
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
        merchantExperiment experiment: String? = nil,
        merchantPassedUserAction: String? = nil,
        isConfigFromCache: Bool? = nil,
        isVaultRequest: Bool? = nil,
        linkType: LinkType? = nil,
        pageType: String? = nil,
        shopperSessionID: String? = nil
    ) {
        postedApplicationState = applicationState
        postedButtonType = buttonType
        postedButtonOrder = buttonOrder
        postedPageType = pageType
        postedContextID = contextID
        postedLinkType = linkType
        postedIsVaultRequest = isVaultRequest ?? false
        postedMerchantExperiment = experiment
        postedMerchantPassedUserAction = merchantPassedUserAction
        postedAppSwitchURL[eventName] = appSwitchURL?.absoluteString
        postedShopperSessionID = shopperSessionID
        postedDidEnablePayPalAppSwitch = didEnablePayPalAppSwitch
        postedDidPayPalServerAttemptAppSwitch = didPayPalServerAttemptAppSwitch
        postedErrorDescription = errorDescription
        postedContextType = contextType

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
