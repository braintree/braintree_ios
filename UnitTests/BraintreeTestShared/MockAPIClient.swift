import Foundation
@testable import BraintreeCore

public class MockAPIClient: BTAPIClient {
    public var lastPOSTPath = ""
    public var lastPOSTParameters = [:] as [AnyHashable: Any]?
    public var lastPOSTAPIClientHTTPType: BTAPIClientHTTPService?

    public var lastGETPath = ""
    public var lastGETParameters = [:] as [String : String]?
    public var lastGETAPIClientHTTPType: BTAPIClientHTTPService?

    public var postedAnalyticsEvents : [String] = []

    @objc public var cannedConfigurationResponseBody : BTJSON? = nil
    @objc public var cannedConfigurationResponseError : NSError? = nil

    public var cannedResponseError : NSError? = nil
    public var cannedHTTPURLResponse : HTTPURLResponse? = nil
    public var cannedResponseBody : BTJSON? = nil
    var cannedMetadata : BTClientMetadata? = nil

    var fetchedPaymentMethods = false
    var fetchPaymentMethodsSorting = false

    override init?(authorization: String, sendAnalyticsEvent: Bool = false) {
        super.init(authorization: authorization, sendAnalyticsEvent: sendAnalyticsEvent)
    }
    
    public override func get(_ path: String, parameters: [String: String]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        self.get(path, parameters: parameters, httpType:.gateway, completion: completionBlock)
    }

    public override func post(_ path: String, parameters: [String: Any]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        self.post(path, parameters: parameters, httpType:.gateway, completion: completionBlock)
    }

    public override func get(_ path: String, parameters: [String: String]?, httpType: BTAPIClientHTTPService, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        lastGETPath = path
        lastGETParameters = parameters
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
    
    public override func fetchOrReturnRemoteConfiguration(_ completionBlock: @escaping (BTConfiguration?, Error?) -> Void) {
        guard let responseBody = cannedConfigurationResponseBody else {
            completionBlock(nil, cannedConfigurationResponseError)
            return
        }
        completionBlock(BTConfiguration(json: responseBody), cannedConfigurationResponseError)
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

    public override func sendAnalyticsEvent(_ name: String, errorDescription: String? = nil, correlationID: String? = nil) {
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
