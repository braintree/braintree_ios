import XCTest
import BraintreeTestShared

@testable import BraintreeCore

class TokenizationKey_Tests: XCTestCase {
    
    func testConfigURL_forDevelopment_setsProperURL() throws {
        let sut = try TokenizationKey("development_tokenization_key")
        XCTAssertEqual(sut.configURL.absoluteString, "http://localhost:3000/merchants/key/client_api/v1/configuration")
    }
    
    func testConfigURL_forSandbox_setsProperURL() throws {
        let sut = try TokenizationKey("sandbox_tokenization_key")
        XCTAssertEqual(sut.configURL.absoluteString, "https://api.sandbox.braintreegateway.com/merchants/key/client_api/v1/configuration")
    }
    
    func testConfigURL_forProduction_setsProperURL() throws {
        let sut = try TokenizationKey("production_tokenization_key")
        XCTAssertEqual(sut.configURL.absoluteString, "https://api.braintreegateway.com:443/merchants/key/client_api/v1/configuration")
    }
    
    func testInit_forInvalidEnvironment_throwsError() {
        do {
            let sut = try TokenizationKey("fake-env_part2_part3")
        } catch {
            let error = error as NSError
            XCTAssertEqual(error.localizedDescription, "Invalid tokenization key. Please ensure your server is generating a valid Braintree Tokenization Key.")
            XCTAssertEqual(error.code, 0)
            XCTAssertEqual(error.domain, "com.braintreepayments.BTTokenizationKeyErrorDomain")
        }
    }
    
    func testInit_forInvalidFormat_throwsError() {
        do {
            let sut = try TokenizationKey("invalid_tokenization_key_format_example")
        } catch {
            let error = error as NSError
            XCTAssertEqual(error.localizedDescription, "Invalid tokenization key. Please ensure your server is generating a valid Braintree Tokenization Key.")
            XCTAssertEqual(error.code, 0)
            XCTAssertEqual(error.domain, "com.braintreepayments.BTTokenizationKeyErrorDomain")
        }
    }
}

