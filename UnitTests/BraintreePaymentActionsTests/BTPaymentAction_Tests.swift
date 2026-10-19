import XCTest
@testable import BraintreeCore
@testable import BraintreePaymentActions

class BTPaymentAction_Tests: XCTestCase {

    // MARK: - init(json:) - Required Fields

    func testInitJSON_missingID_throwsMissingID() {
        let json = BTJSON(value: ["status": "SUCCEEDED"] as [String: Any])

        XCTAssertThrowsError(try BTPaymentAction(json: json)) { error in
            XCTAssertEqual(error as? BTPaymentActionError, .missingID)
        }
    }

    func testInitJSON_emptyID_throwsMissingID() {
        let json = BTJSON(value: ["id": "", "status": "SUCCEEDED"] as [String: Any])

        XCTAssertThrowsError(try BTPaymentAction(json: json)) { error in
            XCTAssertEqual(error as? BTPaymentActionError, .missingID)
        }
    }

    func testInitJSON_missingStatus_throwsMissingStatus() {
        let json = BTJSON(value: ["id": "payment-action-id"] as [String: Any])

        XCTAssertThrowsError(try BTPaymentAction(json: json)) { error in
            XCTAssertEqual(error as? BTPaymentActionError, .missingStatus)
        }
    }

    // MARK: - init(json:) - nextAction

    func testInitJSON_withoutNextAction_nextActionIsNil() throws {
        let json = BTJSON(value: ["id": "payment-action-id", "status": "REQUIRES_CUSTOMER_ACTION"] as [String: Any])

        let paymentAction = try BTPaymentAction(json: json)

        XCTAssertNil(paymentAction.nextAction)
    }

    func testInitJSON_withThreeDSecureAuthenticationNextAction_parsesNextAction() throws {
        let json = BTJSON(value: [
            "id": "payment-action-id",
            "status": "REQUIRES_CUSTOMER_ACTION",
            "nextAction": [
                "__typename": "PaymentActionThreeDSecureAuthentication",
                "bin": "401288"
            ] as [String: Any]
        ] as [String: Any])

        let paymentAction = try BTPaymentAction(json: json)

        XCTAssertEqual(
            paymentAction.nextAction,
            .threeDSecureAuthentication(BTPaymentActionThreeDSecureAuthenticationNextAction(bin: "401288"))
        )
    }

    func testInitJSON_withUnrecognizedNextAction_doesNotThrow() throws {
        let json = BTJSON(value: [
            "id": "payment-action-id",
            "status": "REQUIRES_CUSTOMER_ACTION",
            "nextAction": [
                "__typename": "PaymentActionRedirectUrl",
                "redirectUrl": "https://example.com"
            ] as [String: Any]
        ] as [String: Any])

        let paymentAction = try BTPaymentAction(json: json)

        XCTAssertEqual(paymentAction.nextAction, .unrecognized(typeName: "PaymentActionRedirectUrl"))
    }

    // MARK: - memberwise init defaults

    func testMemberwiseInit_defaultsNextActionToNil() {
        let paymentAction = BTPaymentAction(id: "payment-action-id", status: .succeeded)

        XCTAssertNil(paymentAction.nextAction)
    }
}
