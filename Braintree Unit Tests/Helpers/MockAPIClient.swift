import BraintreeCore

class MockAPIClient : BTAPIClient {
    var lastPOSTPath = ""
    var lastPOSTParameters = [:] as [NSObject : AnyObject]?
    var lastGETPath = ""
    var lastGETParameters = [:] as [NSObject : AnyObject]?
    var postedAnalyticsEvents : [String] = []

    var cannedConfigurationResponseBody : BTJSON? = nil
    var cannedConfigurationResponseError : NSError? = nil

    var cannedResponseError : NSError? = nil
    var cannedHTTPURLResponse : NSHTTPURLResponse? = nil
    var cannedResponseBody : BTJSON? = nil

    override func GET(path: String, parameters: [NSObject : AnyObject]?, completion completionBlock: ((BTJSON?, NSHTTPURLResponse?, NSError?) -> Void)?) {
        lastGETPath = path
        lastGETParameters = parameters

        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(cannedResponseBody, cannedHTTPURLResponse, cannedResponseError)
    }

    override func POST(path: String, parameters: [NSObject : AnyObject]?, completion completionBlock: ((BTJSON?, NSHTTPURLResponse?, NSError?) -> Void)?) {
        lastPOSTPath = path
        lastPOSTParameters = parameters

        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(cannedResponseBody, cannedHTTPURLResponse, cannedResponseError)
    }

    override func fetchOrReturnRemoteConfiguration(completionBlock: (BTConfiguration?, NSError?) -> Void) {
        guard let responseBody = cannedConfigurationResponseBody else {
            completionBlock(nil, cannedConfigurationResponseError)
            return
        }
        completionBlock(BTConfiguration(JSON: responseBody), cannedConfigurationResponseError)
    }

    /// BTAPIClient gets copied by other classes like BTPayPalDriver, BTVenmoDriver, etc.
    /// This copy causes MockAPIClient to lose its stubbed data (canned responses), so the
    /// workaround for tests is to stub copyWithSource:integration: to *not* copy itself
    override func copyWithSource(source: BTClientMetadataSourceType, integration: BTClientMetadataIntegrationType) -> Self {
        return self
    }

    override func postAnalyticsEvent(name: String!, completion completionBlock: ((NSError!) -> Void)!) {
        postedAnalyticsEvents.append(name)
    }
}
