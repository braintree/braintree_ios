import Foundation
@testable import BraintreeCore

@objc public class FakeHTTP: BTHTTP {
    @objc public var GETRequestCount: Int = 0
    @objc public var POSTRequestCount: Int = 0
    @objc public var lastRequestEndpoint: String?
    public var lastRequestMethod: String?
    public var lastPOSTRequestHeaders: [String: String]? = [:]
    @objc public var lastRequestParameters: [String: Any]?
    var stubMethod: String?
    var stubEndpoint: String?
    public var cannedResponse: BTJSON?
    @objc public var cannedConfiguration: BTJSON?
    @objc public var cannedStatusCode: Int = 0
    public var cannedError: Error?

    @objc public static func fakeHTTP() -> FakeHTTP {
        let fakeTokenizationKey = try! TokenizationKey("development_tokenization_key")
        return self.init(authorization: fakeTokenizationKey, customBaseURL: URL(string: "http://fake.com")!)
    }

    @objc public func stubRequest(withMethod httpMethod: String, toEndpoint endpoint:String, respondWith response: Any, statusCode: Int) {
        stubMethod = httpMethod
        stubEndpoint = endpoint
        cannedResponse = BTJSON(value: response)
        cannedStatusCode = statusCode
    }

    @objc public func stubRequest(withMethod httpMethod: String, toEndpoint endpoint:String, respondWithError error: Error) {
        stubMethod = httpMethod
        stubEndpoint = endpoint
        cannedError = error
    }
    
    public override func get(_ path: String, configuration: BTConfiguration? = nil, parameters: Encodable? = nil, completion: BTHTTP.RequestCompletion?) {
        GETRequestCount += 1
        lastRequestEndpoint = path
        lastRequestParameters = try? parameters?.toDictionary()
        lastRequestMethod = "GET"

        if cannedError != nil {
            dispatchQueue.async {
                completion?(nil, nil, self.cannedError)
            }
        } else {
            let httpResponse = HTTPURLResponse(url: URL(string: path)!, statusCode: cannedStatusCode, httpVersion: nil, headerFields: nil)
            dispatchQueue.async {
                if path.contains("v1/configuration") {
                    completion?(self.cannedConfiguration, httpResponse, nil)
                } else {
                    completion?(self.cannedResponse, httpResponse, nil)
                }
            }
        }
    }

    public override func post(_ path: String, configuration: BTConfiguration? = nil, parameters: [String: Any]? = nil, headers: [String: String]? = nil, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        POSTRequestCount += 1
        lastRequestEndpoint = path
        lastRequestParameters = parameters
        lastRequestMethod = "POST"
        lastPOSTRequestHeaders = headers
        if cannedError != nil {
            dispatchQueue.async {
                completion?(nil, nil, self.cannedError)
            }
        } else {
            let httpResponse = HTTPURLResponse(url: URL(string: path)!, statusCode: cannedStatusCode, httpVersion: nil, headerFields: nil)
            dispatchQueue.async {
                completion?(self.cannedResponse, httpResponse, nil)
            }
        }
    }
}

@objc public class FakeGraphQLHTTP: BTGraphQLHTTP {
    var POSTRequestCount: Int = 0
    @objc public var lastRequestParameters: [String: Any]?
    @objc public var cannedConfiguration: BTJSON?

    @objc public static func fakeHTTP() -> FakeGraphQLHTTP {
        let fakeTokenizationKey = try! TokenizationKey("development_tokenization_key")
        return self.init(authorization: fakeTokenizationKey, customBaseURL: URL(string: "http://fake.com")!)
    }

    public override func post(_ path: String, configuration: BTConfiguration? = nil, parameters: [String: Any]?, headers: [String: String]? = nil, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        POSTRequestCount += 1
        lastRequestParameters = parameters
        completion?(self.cannedConfiguration, nil, nil)
    }
}
