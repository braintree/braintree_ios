import XCTest
import BraintreeTestShared

@testable import BraintreeCoreSwift

class BTClientToken_Tests: XCTestCase {

    func testInitialization_whenVersionIsUnsupported_returnsError() {
        do {
            let clientToken = try BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 2, overrides: ["version": 0]))
            XCTAssertNil(clientToken)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTClientTokenError.errorDomain)
            XCTAssertEqual(error.code, BTClientTokenError.unsupportedVersion.rawValue)
            XCTAssertEqual(error.localizedDescription, BTClientTokenError.unsupportedVersion.localizedDescription)
        }
    }

    func testInitialization_withV1RawJSONClientTokens_isSuccessful() throws {
        let configURLString = "https://api.example.com:443/merchants/a_merchant_id/client_api/v1/configuration"
        let configURLOverride = ["configUrl": configURLString]

        let clientToken = try XCTUnwrap(
            BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 1, overrides: configURLOverride))
        )

        XCTAssertEqual(clientToken.authorizationFingerprint, "an_authorization_fingerprint")
        XCTAssertEqual(clientToken.configURL, URL(string: configURLString))
    }

    func testInitialization_withV2Base64EncodedClientTokens_isSuccessful() throws {
        let configURLString = "https://api.example.com:443/merchants/a_merchant_id/client_api/v1/configuration"
        let configURLOverride = ["configUrl": configURLString]

        let clientToken = try XCTUnwrap(
            BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 2, overrides: configURLOverride))
        )

        XCTAssertEqual(clientToken.authorizationFingerprint, "an_authorization_fingerprint")
        XCTAssertEqual(clientToken.configURL, URL(string: configURLString))
    }

    func testInitialization_withInvalidJSON_returnsError() {
        do {
            let clientToken = try BTClientToken(clientToken: "definitely_not_a_client_token")
            XCTAssertNil(clientToken)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTClientTokenError.errorDomain)
            XCTAssertEqual(error.code, BTClientTokenError.invalidJSON.rawValue)
            XCTAssertEqual(error.localizedDescription, BTClientTokenError.invalidJSON.localizedDescription)
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
            XCTAssertEqual(error.code, BTClientTokenError.invalidConfigURL.rawValue)
            XCTAssertEqual(error.localizedDescription, BTClientTokenError.invalidConfigURL.localizedDescription)
        }
    }

    func testInitialization_whenAuthorizationFingerprintIsOmitted_returnsError() {
        do {
            let clientTokenRawJSON = TestClientTokenFactory.token(withVersion: 2, overrides: ["authorizationFingerprint": NSNull()])
            let clientToken = try BTClientToken(clientToken: clientTokenRawJSON)
            XCTAssertNil(clientToken)
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTClientTokenError.errorDomain)
            XCTAssertEqual(error.code, BTClientTokenError.invalidAuthorizationFingerprint.rawValue)
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
            XCTAssertEqual(error.code, BTClientTokenError.invalidAuthorizationFingerprint.rawValue)
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
        XCTAssertEqual(returnedClientToken?.authorizationFingerprint, authFingerprintString)
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
        XCTAssertEqual(copiedClientToken?.authorizationFingerprint, clientToken.authorizationFingerprint)
        XCTAssertEqual(copiedClientToken?.originalValue, clientToken.originalValue)
    }
}
