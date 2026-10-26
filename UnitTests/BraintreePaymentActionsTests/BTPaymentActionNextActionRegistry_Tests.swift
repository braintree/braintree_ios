import XCTest
@testable import BraintreeCore
@testable import BraintreePaymentActions

class BTPaymentActionNextActionRegistry_Tests: XCTestCase {

    var registry: BTPaymentActionNextActionRegistry!

    override func setUp() {
        super.setUp()
        registry = BTPaymentActionNextActionRegistry()
    }

    // MARK: - resolve(json:) - No nextAction

    func testResolve_nilNextAction_returnsNil() throws {
        let json = BTJSON(value: NSNull())

        XCTAssertNil(try registry.resolve(json: json))
    }

    // MARK: - resolve(json:) - Registered 3DS Members

    func testResolve_threeDSecureAuthentication_returnsTypedCase() throws {
        let json = BTJSON(value: [
            "__typename": "PaymentActionThreeDSecureAuthentication",
            "bin": "401288"
        ] as [String: Any])

        let resolved = try registry.resolve(json: json)

        XCTAssertEqual(
            resolved,
            .threeDSecureAuthentication(BTPaymentActionThreeDSecureAuthenticationNextAction(bin: "401288"))
        )
    }

    func testResolve_threeDSecureAuthentication_missingBin_throwsDecodingFailure() {
        let json = BTJSON(value: ["__typename": "PaymentActionThreeDSecureAuthentication"] as [String: Any])

        XCTAssertThrowsError(try registry.resolve(json: json)) { error in
            XCTAssertEqual(error as? BTPaymentActionError, .decodingFailure)
        }
    }

    func testResolve_threeDSecureChallenge_returnsTypedCase() throws {
        let json = BTJSON(value: [
            "__typename": "PaymentActionThreeDSecureChallenge",
            "acsUrl": "https://acs.example.com",
            "acsRenderingType": "otp",
            "challengePayload": "payload-data",
            "mpiTransactionId": "mpi-txn-1"
        ] as [String: Any])

        let resolved = try registry.resolve(json: json)

        XCTAssertEqual(
            resolved,
            .threeDSecureChallenge(
                BTPaymentActionThreeDSecureChallengeNextAction(
                    acsURL: URL(string: "https://acs.example.com")!,
                    acsRenderingType: "otp",
                    challengePayload: "payload-data",
                    mpiTransactionID: "mpi-txn-1"
                )
            )
        )
    }

    func testResolve_threeDSecureChallenge_withoutOptionalFields_succeeds() throws {
        let json = BTJSON(value: [
            "__typename": "PaymentActionThreeDSecureChallenge",
            "acsUrl": "https://acs.example.com",
            "challengePayload": "payload-data"
        ] as [String: Any])

        let resolved = try registry.resolve(json: json)

        XCTAssertEqual(
            resolved,
            .threeDSecureChallenge(
                BTPaymentActionThreeDSecureChallengeNextAction(
                    acsURL: URL(string: "https://acs.example.com")!,
                    acsRenderingType: nil,
                    challengePayload: "payload-data",
                    mpiTransactionID: nil
                )
            )
        )
    }

    func testResolve_threeDSecureChallenge_missingRequiredField_throwsDecodingFailure() {
        let json = BTJSON(value: [
            "__typename": "PaymentActionThreeDSecureChallenge",
            "acsUrl": "https://acs.example.com"
        ] as [String: Any])

        XCTAssertThrowsError(try registry.resolve(json: json)) { error in
            XCTAssertEqual(error as? BTPaymentActionError, .decodingFailure)
        }
    }

    // MARK: - resolve(json:) - Unrecognized Members

    func testResolve_unknownTypename_returnsUnrecognized() throws {
        let json = BTJSON(value: ["__typename": "PaymentActionQrCode", "id": "qr-1"] as [String: Any])

        let resolved = try registry.resolve(json: json)

        XCTAssertEqual(resolved, .unrecognized(typeName: "PaymentActionQrCode"))
    }

    func testResolve_missingTypename_returnsUnrecognizedWithNilTypeName() throws {
        let json = BTJSON(value: ["someField": "someValue"] as [String: Any])

        let resolved = try registry.resolve(json: json)

        XCTAssertEqual(resolved, .unrecognized(typeName: nil))
    }

    // MARK: - register(typeName:factory:)

    func testRegister_customTypeName_overridesResolution() throws {
        registry.register(typeName: "PaymentActionCustomTest") { _ in
            .threeDSecureAuthentication(BTPaymentActionThreeDSecureAuthenticationNextAction(bin: "custom"))
        }

        let json = BTJSON(value: ["__typename": "PaymentActionCustomTest"] as [String: Any])
        let resolved = try registry.resolve(json: json)

        XCTAssertEqual(
            resolved,
            .threeDSecureAuthentication(BTPaymentActionThreeDSecureAuthenticationNextAction(bin: "custom"))
        )
    }
}
