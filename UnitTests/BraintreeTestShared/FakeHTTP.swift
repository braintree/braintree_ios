import BraintreeCore
import BraintreeCore.Private

@objc public class FakeHTTP: BTHTTP {
    @objc public var GETRequestCount: Int = 0
    @objc public var POSTRequestCount: Int = 0
    @objc public var lastRequestEndpoint: String?
    public var lastRequestMethod: String?
    @objc public var lastRequestParameters: Dictionary<AnyHashable, Any>?
    var stubMethod: String?
    var stubEndpoint: String?
    public var cannedResponse: BTJSON?
    @objc public var cannedConfiguration: BTJSON?
    @objc public var cannedStatusCode: Int = 0
    public var cannedError: Error?

    required override init(baseURL: URL) {
        super.init(baseURL: baseURL)
    }

    @objc public static func fakeHTTP() -> FakeHTTP {
        return self.init(baseURL: URL.init(string: "http://fake.com")!)
    }

    @objc public func stubRequest(withMethod httpMethod: String, toEndpoint endpoint:String, respondWith response: Any, statusCode: Int) {
        stubMethod = httpMethod
        stubEndpoint = endpoint
        cannedResponse = BTJSON.init(value: response)
        cannedStatusCode = statusCode
    }

    @objc public func stubRequest(withMethod httpMethod: String, toEndpoint endpoint:String, respondWithError error: Error) {
        stubMethod = httpMethod
        stubEndpoint = endpoint
        cannedError = error
    }

    public override func get(_ endpoint: String, parameters: [String : String]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        GETRequestCount += 1
        lastRequestEndpoint = endpoint
        lastRequestParameters = parameters
        lastRequestMethod = "GET"

        if cannedError != nil {
            dispatchQueue.async {
                completionBlock!(nil, nil, self.cannedError)
            }
        } else {
            let httpResponse = HTTPURLResponse.init(url: URL.init(string: endpoint)!, statusCode: cannedStatusCode, httpVersion: nil, headerFields: nil)
            dispatchQueue.async {
                if endpoint.contains("v1/configuration") {
                    completionBlock!(self.cannedConfiguration, httpResponse, nil)
                } else {
                    completionBlock!(self.cannedResponse, httpResponse, nil)
                }
            }
        }
    }
    
    public override func get(_ endpoint: String, parameters: [String : String]?, shouldCache: Bool, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        GETRequestCount += 1
        lastRequestEndpoint = endpoint
        lastRequestParameters = parameters
        lastRequestMethod = "GET"

        if cannedError != nil {
            dispatchQueue.async {
                completionBlock!(nil, nil, self.cannedError)
            }
        } else {
            let httpResponse = HTTPURLResponse.init(url: URL.init(string: endpoint)!, statusCode: cannedStatusCode, httpVersion: nil, headerFields: nil)
            dispatchQueue.async {
                if endpoint.contains("v1/configuration") {
                    completionBlock!(self.cannedConfiguration, httpResponse, nil)
                } else {
                    completionBlock!(self.cannedResponse, httpResponse, nil)
                }
            }
        }
    }

    public override func post(_ endpoint: String, parameters: [AnyHashable : Any]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        POSTRequestCount += 1
        lastRequestEndpoint = endpoint
        lastRequestParameters = parameters
        lastRequestMethod = "POST"
        if cannedError != nil {
            dispatchQueue.async {
                completionBlock!(nil, nil, self.cannedError)
            }
        } else {
            let httpResponse = HTTPURLResponse.init(url: URL.init(string: endpoint)!, statusCode: cannedStatusCode, httpVersion: nil, headerFields: nil)
            dispatchQueue.async {
                completionBlock!(self.cannedResponse, httpResponse, nil)
            }
        }
    }
}

@objc public class FakeGraphQLHTTP: BTGraphQLHTTP {
    var POSTRequestCount: Int = 0
    @objc public var lastRequestParameters: Dictionary<AnyHashable, Any>?

    required override init(baseURL: URL) {
        super.init(baseURL: baseURL)
    }

    @objc public static func fakeHTTP() -> FakeGraphQLHTTP {
        return self.init(baseURL: URL.init(string: "http://fake.com")!)
    }

    public override func post(_ endpoint: String, parameters: [AnyHashable : Any]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        POSTRequestCount += 1
        lastRequestParameters = parameters
        completionBlock!(nil, nil, nil)
    }
}

@objc public class FakeAPIHTTP: BTAPIHTTP {
    var POSTRequestCount: Int = 0
    @objc public var lastRequestParameters: Dictionary<AnyHashable, Any>?

    required override init(baseURL: URL) {
        super.init(baseURL: baseURL)
    }

    @objc public static func fakeHTTP() -> FakeAPIHTTP {
        return self.init(baseURL: URL.init(string: "http://fake.com")!)
    }

    public override func post(_ endpoint: String, parameters: [AnyHashable : Any]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        POSTRequestCount += 1
        lastRequestParameters = parameters
        completionBlock!(nil, nil, nil)
    }
}
