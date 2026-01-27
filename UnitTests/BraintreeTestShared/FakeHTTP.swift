import Foundation
@testable import BraintreeCore

@objc public final class FakeHTTP: BTHTTP, @unchecked Sendable {
    @objc public nonisolated(unsafe) var GETRequestCount: Int = 0
    @objc public nonisolated(unsafe) var POSTRequestCount: Int = 0
    @objc public nonisolated(unsafe) var lastRequestEndpoint: String?
    public nonisolated(unsafe) var lastRequestMethod: String?
    public nonisolated(unsafe) var lastPOSTRequestHeaders: [String: String]? = [:]
    @objc public nonisolated(unsafe) var lastRequestParameters: [String: Any]?
    nonisolated(unsafe) var stubMethod: String?
    nonisolated(unsafe) var stubEndpoint: String?
    public nonisolated(unsafe) var cannedResponse: BTJSON?
    @objc public nonisolated(unsafe) var cannedConfiguration: BTJSON?
    @objc public nonisolated(unsafe) var cannedStatusCode: Int = 0
    public nonisolated(unsafe) var cannedError: Error?

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

    public override func get(_ path: String, configuration: BTConfiguration? = nil, parameters: Encodable? = nil) async throws -> (BTJSON?, HTTPURLResponse?) {
        GETRequestCount += 1
        lastRequestEndpoint = path
        lastRequestParameters = try? parameters?.toDictionary()
        lastRequestMethod = "GET"

        if let error = cannedError {
            throw error
        }
        let httpResponse = HTTPURLResponse(url: URL(string: path)!, statusCode: cannedStatusCode, httpVersion: nil, headerFields: nil)
        if path.contains("v1/configuration") {
            return (cannedConfiguration, httpResponse)
        } else {
            return (cannedResponse, httpResponse)
        }
    }

    public override func post(_ path: String, configuration: BTConfiguration? = nil, parameters: Encodable? = nil, headers: [String: String]? = nil, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        POSTRequestCount += 1
        lastRequestEndpoint = path
        lastRequestParameters = try? parameters?.toDictionary()
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
    
    public override func post(_ path: String, configuration: BTConfiguration? = nil, parameters: Encodable? = nil, headers: [String: String]? = nil) async throws -> (BTJSON?, HTTPURLResponse?) {
        POSTRequestCount += 1
        lastRequestEndpoint = path
        lastRequestParameters = try? parameters?.toDictionary()
        lastRequestMethod = "POST"
        lastPOSTRequestHeaders = headers
        if let error = cannedError {
            throw error
        }
        let httpResponse = HTTPURLResponse(url: URL(string: path)!, statusCode: cannedStatusCode, httpVersion: nil, headerFields: nil)
        return (cannedResponse, httpResponse)
    }
}

@objc public final class FakeGraphQLHTTP: BTGraphQLHTTP, @unchecked Sendable {
    nonisolated(unsafe) var POSTRequestCount: Int = 0
    @objc public nonisolated(unsafe) var lastRequestParameters: [String: Any]?
    @objc public nonisolated(unsafe) var cannedConfiguration: BTJSON?

    @objc public static func fakeHTTP() -> FakeGraphQLHTTP {
        let fakeTokenizationKey = try! TokenizationKey("development_tokenization_key")
        return self.init(authorization: fakeTokenizationKey, customBaseURL: URL(string: "http://fake.com")!)
    }

    public override func post(_ path: String, configuration: BTConfiguration? = nil, parameters: Encodable? = nil, headers: [String: String]? = nil, completion: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        POSTRequestCount += 1
        lastRequestParameters = try? parameters?.toDictionary()
        completion?(self.cannedConfiguration, nil, nil)
    }
    
    public override func post(_ path: String, configuration: BTConfiguration? = nil, parameters: Encodable? = nil, headers: [String: String]? = nil) async throws -> (BTJSON?, HTTPURLResponse?) {
        POSTRequestCount += 1
        lastRequestParameters = try? parameters?.toDictionary()
        return (self.cannedConfiguration, nil)
    }
}
