class MockAPIClient : BTAPIClient {
    var lastPOSTPath = ""
    var lastPOSTParameters = [:] as [AnyHashable: Any]?
    var lastPOSTAPIClientHTTPType: BTAPIClientHTTPType?
    var lastGETPath = ""
    var lastGETParameters = [:] as [String : String]?
    var lastGETAPIClientHTTPType: BTAPIClientHTTPType?
    var postedAnalyticsEvents : [String] = []

    @objc var cannedConfigurationResponseBody : BTJSON? = nil
    @objc var cannedConfigurationResponseError : NSError? = nil

    var cannedResponseError : NSError? = nil
    var cannedHTTPURLResponse : HTTPURLResponse? = nil
    var cannedResponseBody : BTJSON? = nil
    var cannedMetadata : BTClientMetadata? = nil

    var fetchedPaymentMethods = false
    var fetchPaymentMethodsSorting = false
    
    override func get(_ path: String, parameters: [String : String]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        self.get(path, parameters: parameters, httpType:.gateway, completion: completionBlock)
    }

    override func post(_ path: String, parameters: [AnyHashable : Any]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        self.post(path, parameters: parameters, httpType:.gateway, completion: completionBlock)
    }

    override func get(_ path: String, parameters: [String : String]?, httpType: BTAPIClientHTTPType, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        lastGETPath = path
        lastGETParameters = parameters
        lastGETAPIClientHTTPType = httpType
        
        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(cannedResponseBody, cannedHTTPURLResponse, cannedResponseError)
    }
    
    override func post(_ path: String, parameters: [AnyHashable : Any]?, httpType: BTAPIClientHTTPType, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        lastPOSTPath = path
        lastPOSTParameters = parameters
        lastPOSTAPIClientHTTPType = httpType
        
        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(cannedResponseBody, cannedHTTPURLResponse, cannedResponseError)
    }
    
    override func fetchOrReturnRemoteConfiguration(_ completionBlock: @escaping (BTConfiguration?, Error?) -> Void) {
        guard let responseBody = cannedConfigurationResponseBody else {
            completionBlock(nil, cannedConfigurationResponseError)
            return
        }
        completionBlock(BTConfiguration(json: responseBody), cannedConfigurationResponseError)
    }

    override func fetchPaymentMethodNonces(_ completion: @escaping ([BTPaymentMethodNonce]?, Error?) -> Void) {
        fetchedPaymentMethods = true
        fetchPaymentMethodsSorting = false
        completion([], nil)
    }
    
    override func fetchPaymentMethodNonces(_ defaultFirst: Bool, completion: @escaping ([BTPaymentMethodNonce]?, Error?) -> Void) {
        fetchedPaymentMethods = true
        fetchPaymentMethodsSorting = false
        completion([], nil)
    }

    /// BTAPIClient gets copied by other classes like BTPayPalDriver, BTVenmoDriver, etc.
    /// This copy causes MockAPIClient to lose its stubbed data (canned responses), so the
    /// workaround for tests is to stub copyWithSource:integration: to *not* copy itself
    override func copy(with source: BTClientMetadataSourceType, integration: BTClientMetadataIntegrationType) -> Self {
        return self
    }

    override func sendAnalyticsEvent(_ name: String) {
        postedAnalyticsEvents.append(name)
    }

    func didFetchPaymentMethods(sorted: Bool) -> Bool {
        return fetchedPaymentMethods && fetchPaymentMethodsSorting == sorted
    }

    override var metadata: BTClientMetadata {
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
