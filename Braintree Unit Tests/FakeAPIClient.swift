import Foundation
import Braintree

class FakeAPIClient : BTAPIClient {
    static let fakeNonce = "fake-nonce"
    static let baseUrl = NSURL(string: "https://example.com")!

    override func POST(endpoint: String!, parameters: BTJSON!, completion completionBlock: BTAPIClientCompletionBlock!) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let json = BTJSON(value: ["creditCards": [["nonce": FakeAPIClient.fakeNonce, "description": "Visa Ending in 11"]]])
            let response = NSHTTPURLResponse(URL: FakeAPIClient.baseUrl, statusCode: 201, HTTPVersion: "1.1", headerFields: nil)
            let error : NSError? = nil
            completionBlock(json, response, error)
        }
    }
}
