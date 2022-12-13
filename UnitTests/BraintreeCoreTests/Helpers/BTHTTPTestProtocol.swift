import Foundation
import BraintreeCore

@objcMembers class BTHTTPTestProtocol: URLProtocol {

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let client = client else { return }

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )

        let archivedRequest: Data = try! NSKeyedArchiver.archivedData(withRootObject: request, requiringSecureCoding: true)
        let base64ArchivedRequest = archivedRequest.base64EncodedString()
        var requestBodyData: Data? = nil

        if request.httpBodyStream != nil {
            guard let inputStream = request.httpBodyStream else { return }
            inputStream.open()
            var mutableBodyData = Data()

            while inputStream.hasBytesAvailable {
                let bufferSize: Int = 128
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                let bytesRead = inputStream.read(buffer, maxLength: bufferSize)
                mutableBodyData.append(buffer, count: bytesRead)
            }
            inputStream.close()
            requestBodyData = mutableBodyData
        } else {
            requestBodyData = request.httpBody ?? Data()
        }

        let responseBody = [
            "request": base64ArchivedRequest,
            "requestBody": String(data: requestBodyData ?? Data(), encoding: .utf8)
        ]

        client.urlProtocol(self, didReceive: response!, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
        client.urlProtocol(self, didLoad: try! JSONSerialization.data(withJSONObject: responseBody, options: .prettyPrinted))
        client.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // no-op
    }

    static func testBaseURL() -> URL {
        var components = URLComponents()
        components.scheme = "bt-http-test"
        components.host = "base.example.com"
        components.path = "/base/path"
        components.port = 1234
        return components.url!
    }

    static func parseRequestFromTestResponseBody(_ responseBody: BTJSON) -> URLRequest {
        let dataToUnarchive = Data(base64Encoded: responseBody["request"].asString() ?? "") ?? Data()
        let urlRequest = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSURLRequest.self, from: dataToUnarchive)! as URLRequest
        return urlRequest ?? URLRequest(url: URL(string: "")!)
    }

    static func parseRequestBodyFromTestResponseBody(_ responseBody: BTJSON) -> String {
        responseBody["requestBody"].asString() ?? ""
    }
}
