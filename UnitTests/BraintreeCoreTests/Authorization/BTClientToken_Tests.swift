import XCTest
import BraintreeTestShared

@testable import BraintreeCore

class BTClientToken_Tests: XCTestCase {

    func testInitialization_whenVersionIsUnsupported_returnsError() {
        do {
            let clientToken = try BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 2, overrides: ["version": 0]))
            XCTAssertNil(clientToken)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTClientTokenError.errorDomain)
            XCTAssertEqual(error.code, 3)
            XCTAssertEqual(error.localizedDescription, BTClientTokenError.unsupportedVersion.localizedDescription)
        }
    }

    func testInitialization_withV1RawJSONClientTokens_isSuccessful() throws {
        let configURLString = "https://api.example.com:443/merchants/a_merchant_id/client_api/v1/configuration"
        let configURLOverride = ["configUrl": configURLString]

        let clientToken = try XCTUnwrap(
            BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 1, overrides: configURLOverride))
        )

        XCTAssertEqual(clientToken.bearer, "an_authorization_fingerprint")
        XCTAssertEqual(clientToken.configURL, URL(string: configURLString))
    }

    func testInitialization_withV2Base64EncodedClientTokens_isSuccessful() throws {
        let configURLString = "https://api.example.com:443/merchants/a_merchant_id/client_api/v1/configuration"
        let configURLOverride = ["configUrl": configURLString]

        let clientToken = try XCTUnwrap(
            BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 2, overrides: configURLOverride))
        )

        XCTAssertEqual(clientToken.bearer, "an_authorization_fingerprint")
        XCTAssertEqual(clientToken.configURL, URL(string: configURLString))
    }

    func testInitialization_withInvalidJSON_returnsError() {
        do {
            let clientToken = try BTClientToken(clientToken: "definitely_not_a_client_token")
            XCTAssertNil(clientToken)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTClientTokenError.errorDomain)
            XCTAssertEqual(error.code, 2)
            XCTAssertEqual(error.localizedDescription, "Invalid client token format. Please ensure your server is generating a valid Braintree ClientToken. Invalid JSON. Expected to find an object at JSON root.")
        }
    }
    
    func testInitialization_withNilVersion_returnsError() {
        do {
            let clientTokenRawJSON = TestClientTokenFactory.token(withVersion: 1, overrides: ["version": nil])
            let clientToken = try BTClientToken(clientToken: clientTokenRawJSON)
            XCTAssertNil(clientToken)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTClientTokenError.errorDomain)
            XCTAssertEqual(error.code, 2)
            XCTAssertEqual(error.localizedDescription, "Invalid client token format. Please ensure your server is generating a valid Braintree ClientToken. Invalid version number. Expected to find an integer for key \"version\".")
        }
    }
    
    func testInitialization_withVersion1Base64Encoding_returnsError() {
        do {
            // Force factory to encode for version 2, then override version number for test case
            let clientTokenRawJSON = TestClientTokenFactory.token(withVersion: 2, overrides: ["version": 1])
            let clientToken = try BTClientToken(clientToken: clientTokenRawJSON)
            XCTAssertNil(clientToken)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTClientTokenError.errorDomain)
            XCTAssertEqual(error.code, 4)
            XCTAssertEqual(error.localizedDescription, "Failed to decode client token. UTF8 encoding is required for Client Token version 1.")
        }
    }
    
    func testInitialization_withVersion2UTF8Encoding_returnsError() {
        do {
            // Force factory to encode for version 1, then override version number for test case
            let clientTokenRawJSON = TestClientTokenFactory.token(withVersion: 1, overrides: ["version": 2])
            let clientToken = try BTClientToken(clientToken: clientTokenRawJSON)
            XCTAssertNil(clientToken)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTClientTokenError.errorDomain)
            XCTAssertEqual(error.code, 4)
            XCTAssertEqual(error.localizedDescription, "Failed to decode client token. Base64 encoding is required for Client Token versions 2 & 3.")
        }
    }

    // MARK: - Edge cases

    func testInitialization_whenConfigURLIsBlank_returnsError() {
        do {
            let clientTokenRawJSON = TestClientTokenFactory.token(withVersion: 2, overrides: ["configUrl": ""])
            let clientToken = try BTClientToken(clientToken: clientTokenRawJSON)
            XCTAssertNil(clientToken)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTClientTokenError.errorDomain)
            XCTAssertEqual(error.code, 1)
            XCTAssertEqual(error.localizedDescription, BTClientTokenError.invalidConfigURL.localizedDescription)
        }
    }

    func testInitialization_whenAuthorizationFingerprintIsOmitted_returnsError() {
        do {
            let clientTokenRawJSON = TestClientTokenFactory.token(withVersion: 2, overrides: ["authorizationFingerprint": nil])
            let clientToken = try BTClientToken(clientToken: clientTokenRawJSON)
            XCTAssertNil(clientToken)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTClientTokenError.errorDomain)
            XCTAssertEqual(error.code, 0)
            XCTAssertEqual(error.localizedDescription, BTClientTokenError.invalidAuthorizationFingerprint.localizedDescription)
        }
    }

    func testInitialization_whenAuthorizationFingerprintIsBlank_returnsError() {
        do {
            let clientTokenRawJSON = TestClientTokenFactory.token(withVersion: 2, overrides: ["authorizationFingerprint": ""])
            let clientToken = try BTClientToken(clientToken: clientTokenRawJSON)
            XCTAssertNil(clientToken)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTClientTokenError.errorDomain)
            XCTAssertEqual(error.code, 0)
            XCTAssertEqual(error.localizedDescription, BTClientTokenError.invalidAuthorizationFingerprint.localizedDescription)
        }
    }

    // MARK: - NSCoding test

    func testNSCoding_afterEncodingAndDecodingClientToken_preservesClientTokenDataIntegrity() throws {
        let authFingerprintString = "an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key"
        let configURLString = "https://api.example.com/client_api/v1/configuration"
        let overrides: [String: Any] = [
            "configUrl": configURLString,
            "authorizationFingerprint": authFingerprintString
        ]

        let clientTokenEncodedJSON = TestClientTokenFactory.token(withVersion: 2, overrides: overrides)
        let clientToken = try XCTUnwrap(BTClientToken(clientToken: clientTokenEncodedJSON))

        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        clientToken.encode(with: coder)

        let decoder = try XCTUnwrap(NSKeyedUnarchiver(forReadingFrom: coder.encodedData))
        let returnedClientToken = BTClientToken(coder: decoder)
        decoder.finishDecoding()

        XCTAssertEqual(returnedClientToken?.configURL, URL(string: configURLString))
        XCTAssertEqual(returnedClientToken?.bearer, authFingerprintString)
    }

    // MARK: - isEqual tests

    func testIsEqual_whenTokensContainTheSameValues_returnsTrue() throws {
        let clientTokenEncodedJSON = TestClientTokenFactory.token(withVersion: 2, overrides: ["authorizationFingerprint": "abcd"])
        let clientToken = try XCTUnwrap(BTClientToken(clientToken: clientTokenEncodedJSON))
        let clientToken2 = try XCTUnwrap(BTClientToken(clientToken: clientTokenEncodedJSON))

        XCTAssertNotNil(clientToken)
        XCTAssertNotNil(clientToken2)
        XCTAssertEqual(clientToken, clientToken2)
    }

    func testIsEqual_whenTokensDoNotContainTheSameValues_returnsFalse() throws {
        let clientTokenString1 = TestClientTokenFactory.token(withVersion: 2, overrides: ["authorizationFingerprint": "one_auth_fingerprint"])
        let clientTokenString2 = TestClientTokenFactory.token(withVersion: 2, overrides: ["authorizationFingerprint": "different_auth_fingerprint"])

        let clientToken = try XCTUnwrap(BTClientToken(clientToken: clientTokenString1))
        let clientToken2 = try XCTUnwrap(BTClientToken(clientToken: clientTokenString2))

        XCTAssertNotNil(clientToken)
        XCTAssertNotNil(clientToken2)
        XCTAssertNotEqual(clientToken, clientToken2)
    }

    // MARK: - NSCopying tests

    func testCopy_returnsAnEquivalentInstance() throws {
        let clientTokenRawJSON = TestClientTokenFactory.token(withVersion: 2)
        let clientToken = try XCTUnwrap(BTClientToken(clientToken: clientTokenRawJSON))
        let copiedClientToken = clientToken.copy() as? BTClientToken

        XCTAssertEqual(copiedClientToken, clientToken)
    }

    func testCopy_returnsAnInstanceWithEqualValues() throws {
        let clientTokenRawJSON = TestClientTokenFactory.token(withVersion: 2)
        let clientToken = try XCTUnwrap(BTClientToken(clientToken: clientTokenRawJSON))
        let copiedClientToken = clientToken.copy() as? BTClientToken

        XCTAssertEqual(copiedClientToken?.configURL, clientToken.configURL)
        XCTAssertEqual(copiedClientToken?.json.asDictionary(), clientToken.json.asDictionary())
        XCTAssertEqual(copiedClientToken?.bearer, clientToken.bearer)
        XCTAssertEqual(copiedClientToken?.originalValue, clientToken.originalValue)
    }
}
