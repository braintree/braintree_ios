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

    public var postedAnalyticsEvents : [String] = []
    public var postedPayPalContextID: String? = nil
    public var postedLinkType: LinkType? = nil
    public var postedIsVaultRequest = false
    public var postedMerchantExperiment: String? = nil
    public var postedPaymentMethodsDisplayed: String? = nil
    public var postedAppSwitchURL: [String: String?] = [:]

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
        _ name: String,
        correlationID: String? = nil,
        errorDescription: String? = nil,
        merchantExperiment experiment: String? = nil,
        isConfigFromCache: Bool? = nil,
        isVaultRequest: Bool? = nil,
        linkType: LinkType? = nil,
        paymentMethodsDisplayed: String? = nil,
        payPalContextID: String? = nil,
        appSwitchURL: URL? = nil
    ) {
        postedPayPalContextID = payPalContextID
        postedLinkType = linkType
        postedIsVaultRequest = isVaultRequest ?? false
        postedMerchantExperiment = experiment
        postedPaymentMethodsDisplayed = paymentMethodsDisplayed
        postedAppSwitchURL[name] = appSwitchURL?.absoluteString
        postedAnalyticsEvents.append(name)
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
