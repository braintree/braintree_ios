import XCTest
@testable import BraintreeCore

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
    
    func testQueryStringWithDict_doesEncode() {
        let dict: NSDictionary = ["configVersion": 3,
                    "authorization_fingerprint" : "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IjIwMTgwNDI2MTYtc2FuZGJveCIsImlzcyI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20ifQ.eyJleHAiOjE2NTUyNDMwNTAsImp0aSI6ImNmZjI2NGE2LTNiNTctNGIzNS04YmNmLTFmNWU4Y2Q4MTNkMSIsInN1YiI6ImRjcHNweTJicndkanIzcW4iLCJpc3MiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwibWVyY2hhbnQiOnsicHVibGljX2lkIjoiZGNwc3B5MmJyd2RqcjNxbiIsInZlcmlmeV9jYXJkX2J5X2RlZmF1bHQiOnRydWV9LCJyaWdodHMiOlsibWFuYWdlX3ZhdWx0Il0sInNjb3BlIjpbIkJyYWludHJlZTpWYXVsdCJdLCJvcHRpb25zIjp7ImN1c3RvbWVyX2lkIjoiMEQyODQ5NDYtMjU4Qy00NDUzLUE2OUYtMEE0MTI1NzFCNTZEIn19.mp7dHtDiAKthHFHFpWzJBEPXtMxLhhW7ldokedpzaH1T18InQ9cPDC2FjL6udsseQ-4enVMPsFtibuY9fuuNUA?customer_id="]
        let expectedResult = "configVersion=3&authorization_fingerprint=eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IjIwMTgwNDI2MTYtc2FuZGJveCIsImlzcyI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20ifQ.eyJleHAiOjE2NTUyNDMwNTAsImp0aSI6ImNmZjI2NGE2LTNiNTctNGIzNS04YmNmLTFmNWU4Y2Q4MTNkMSIsInN1YiI6ImRjcHNweTJicndkanIzcW4iLCJpc3MiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwibWVyY2hhbnQiOnsicHVibGljX2lkIjoiZGNwc3B5MmJyd2RqcjNxbiIsInZlcmlmeV9jYXJkX2J5X2RlZmF1bHQiOnRydWV9LCJyaWdodHMiOlsibWFuYWdlX3ZhdWx0Il0sInNjb3BlIjpbIkJyYWludHJlZTpWYXVsdCJdLCJvcHRpb25zIjp7ImN1c3RvbWVyX2lkIjoiMEQyODQ5NDYtMjU4Qy00NDUzLUE2OUYtMEE0MTI1NzFCNTZEIn19.mp7dHtDiAKthHFHFpWzJBEPXtMxLhhW7ldokedpzaH1T18InQ9cPDC2FjL6udsseQ-4enVMPsFtibuY9fuuNUA%3Fcustomer_id%3D"
        
        let actualResult = BTURLUtils.queryString(from: dict)
        
        XCTAssertEqual(actualResult, expectedResult)
    }
}
