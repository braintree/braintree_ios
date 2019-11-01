import XCTest

class BTURLUtils_Tests: XCTestCase {
    
    // MARK: - queryParametersForURL:
        
    func testQueryParametersForURL_returnsDictionaryWithQueryParameters() {
        let url = URL(string: "url-scheme://x-callback-url/braintree/threedsecure?auth_response=%7B%22paymentMethod%22:%7B%22type%22:%22CreditCard%22,%22nonce%22:%229619abd3-7792-05c7-74e4-848b583de1fa=%22%7D%7D")!
        
        let expectedParameters: [String : String] = ["auth_response":"{\"paymentMethod\":{\"type\":\"CreditCard\",\"nonce\":\"9619abd3-7792-05c7-74e4-848b583de1fa=\"}}"]
        
        XCTAssertEqual(BTURLUtils.queryParameters(for: url).count, expectedParameters.count)
        XCTAssertEqual(BTURLUtils.queryParameters(for: url)["auth_response"], expectedParameters["auth_response"])
    }
    
    func testQueryParametersForURL_returnsEmptyDictionary_whenURLDoesNotHaveQueryParameters() {
        let url = URL(string: "url-scheme://x-callback-url/braintree/threedsecure")!
        
        XCTAssertEqual(BTURLUtils.queryParameters(for: url), [:])
    }
    
    func testQueryParametersForURL_decodesPlusSignAsSpace() {
        let url = URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/threedsecure?auth_response=%7B%22error%22:%7B%22message%22:%22Failed+to+authenticate,+please+try+a+different+form+of+payment.%22%7D%7D")!
        
        let expectedParameters = ["auth_response":"{\"error\":{\"message\":\"Failed to authenticate, please try a different form of payment.\"}}"]

        XCTAssertEqual(BTURLUtils.queryParameters(for: url).count, expectedParameters.count)
        XCTAssertEqual(BTURLUtils.queryParameters(for: url)["auth_response"], expectedParameters["auth_response"])
    }
}
