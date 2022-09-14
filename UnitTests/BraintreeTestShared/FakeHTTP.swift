import BraintreeCore
@testable import BraintreeCoreSwift

@objc public class FakeHTTP: BTHTTP {
    @objc public var GETRequestCount: Int = 0
    @objc public var POSTRequestCount: Int = 0
    @objc public var lastRequestEndpoint: String?
    public var lastRequestMethod: String?
    @objc public var lastRequestParameters: NSDictionary?
    var stubMethod: String?
    var stubEndpoint: String?
    public var cannedResponse: BTJSON?
    @objc public var cannedConfiguration: BTJSON?
    @objc public var cannedStatusCode: Int = 0
    public var cannedError: Error?

    override required init(url: URL) {
        super.init(url: url)
    }

    @objc public static func fakeHTTP() -> FakeHTTP {
        self.init(url: URL(string: "http://fake.com")!)
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

    public override func get(_ path: String, parameters: NSDictionary? = nil, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        GETRequestCount += 1
        lastRequestEndpoint = path
        lastRequestParameters = parameters
        lastRequestMethod = "GET"

        if cannedError != nil {
            dispatchQueue.async {
                completion!(nil, nil, self.cannedError)
            }
        } else {
            let httpResponse = HTTPURLResponse(url: URL(string: path)!, statusCode: cannedStatusCode, httpVersion: nil, headerFields: nil)
            dispatchQueue.async {
                if path.contains("v1/configuration") {
                    completion!(self.cannedConfiguration, httpResponse, nil)
                } else {
                    completion!(self.cannedResponse, httpResponse, nil)
                }
            }
        }
    }
    
    public override func get(_ path: String, parameters: NSDictionary? = nil, shouldCache: Bool, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        GETRequestCount += 1
        lastRequestEndpoint = path
        lastRequestParameters = parameters
        lastRequestMethod = "GET"

        if cannedError != nil {
            dispatchQueue.async {
                completion!(nil, nil, self.cannedError)
            }
        } else {
            let httpResponse = HTTPURLResponse(url: URL(string: path)!, statusCode: cannedStatusCode, httpVersion: nil, headerFields: nil)
            dispatchQueue.async {
                if path.contains("v1/configuration") {
                    completion!(self.cannedConfiguration, httpResponse, nil)
                } else {
                    completion!(self.cannedResponse, httpResponse, nil)
                }
            }
        }
    }

    public override func post(_ path: String, parameters: NSDictionary? = nil, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        POSTRequestCount += 1
        lastRequestEndpoint = path
        lastRequestParameters = parameters
        lastRequestMethod = "POST"
        if cannedError != nil {
            dispatchQueue.async {
                completion!(nil, nil, self.cannedError)
            }
        } else {
            let httpResponse = HTTPURLResponse(url: URL(string: path)!, statusCode: cannedStatusCode, httpVersion: nil, headerFields: nil)
            dispatchQueue.async {
                completion!(self.cannedResponse, httpResponse, nil)
            }
        }
    }
}

@objc public class FakeGraphQLHTTP: BTGraphQLHTTP {
    var POSTRequestCount: Int = 0
    @objc public var lastRequestParameters: NSDictionary?

    required override init(url: URL) {
        super.init(url: url)
    }

    @objc public static func fakeHTTP() -> FakeGraphQLHTTP {
        self.init(url: URL(string: "http://fake.com")!)
    }

    public override func post(_ path: String, parameters: NSDictionary?, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        POSTRequestCount += 1
        lastRequestParameters = parameters
        completion!(nil, nil, nil)
    }
}

@objc public class FakeAPIHTTP: BTAPIHTTP {
    var POSTRequestCount: Int = 0
    @objc public var lastRequestParameters: NSDictionary?

    required override init(url: URL, accessToken: String? = "") {
        super.init(url: url)
    }

    @objc public static func fakeHTTP() -> FakeAPIHTTP {
        self.init(url: URL(string: "http://fake.com")!)
    }

    public override func post(_ path: String, parameters: NSDictionary? = nil, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        POSTRequestCount += 1
        lastRequestParameters = parameters
        completion!(nil, nil, nil)
    }
}
