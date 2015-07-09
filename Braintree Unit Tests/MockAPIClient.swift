import Braintree

class MockAPIClient : BTAPIClient {
    var lastPOSTPath = ""
    var lastPOSTParameters = [:] as [NSObject : AnyObject]

    var cannedConfigurationResponseBody : BTJSON? = nil
    var cannedConfigurationResponseError : NSError? = nil

    var cannedResponseError : NSError? = nil
    var cannedHTTPURLResponse : NSHTTPURLResponse? = nil
    var cannedResponseBody : BTJSON? = nil

    override func POST(path: String, parameters: [NSObject : AnyObject], completion completionBlock: (BTJSON?, NSHTTPURLResponse?, NSError?) -> Void) {
        lastPOSTPath = path
        lastPOSTParameters = parameters

        completionBlock(cannedResponseBody, cannedHTTPURLResponse, cannedResponseError)
    }

    override func fetchOrReturnRemoteConfiguration(completionBlock: (BTJSON?, NSError?) -> Void) {
        completionBlock(cannedConfigurationResponseBody, cannedConfigurationResponseError)
    }
}
