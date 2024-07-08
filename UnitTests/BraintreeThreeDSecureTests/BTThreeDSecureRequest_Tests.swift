import XCTest
import CardinalMobile
@testable import BraintreeTestShared
@testable import BraintreeThreeDSecure

class BTThreeDSecureRequest_Tests: XCTestCase {

    // MARK: - accountTypeAsString

    func testCustomFields_notNil() {
        let request = BTThreeDSecureRequest()
        XCTAssertNil(request.customFields)
        
        request.customFields = ["test": "test"]
        XCTAssertNotNil(request.customFields)
    }

    func testAccountTypeAsString_whenAccountTypeIsCredit_returnsCredit() {
        let request = BTThreeDSecureRequest()
        request.accountType = .credit
        XCTAssertEqual(request.accountType.stringValue, "credit")
    }

    func testAccountTypeAsString_whenAccountTypeIsDebit_returnsDebit() {
        let request = BTThreeDSecureRequest()
        request.accountType = .debit
        XCTAssertEqual(request.accountType.stringValue, "debit")
    }

    func testAccountTypeAsString_whenAccountTypeIsUnspecified_returnsNil() {
        let request = BTThreeDSecureRequest()
        request.accountType = .unspecified
        XCTAssertEqual(request.accountType.stringValue, nil)
    }

    func testAccountTypeAsString_whenAccountTypeIsNotSet_returnsNil() {
        let request = BTThreeDSecureRequest()
        XCTAssertEqual(request.accountType.stringValue, nil)
    }

    // MARK: - shippingMethodAsString

    func testShippingMethodAsString_whenShippingMethodIsSameDay_returns01() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .sameDay
        XCTAssertEqual(request.shippingMethod.stringValue, "01")
    }

    func testShippingMethodAsString_whenShippingMethodIsExpedited_returns02() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .expedited
        XCTAssertEqual(request.shippingMethod.stringValue, "02")
    }

    func testShippingMethodAsString_whenShippingMethodIsPriority_returns03() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .priority
        XCTAssertEqual(request.shippingMethod.stringValue, "03")
    }

    func testShippingMethodAsString_whenShippingMethodIsGround_returns04() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .ground
        XCTAssertEqual(request.shippingMethod.stringValue, "04")
    }

    func testShippingMethodAsString_whenShippingMethodIsElectronicDelivery_returns05() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .electronicDelivery
        XCTAssertEqual(request.shippingMethod.stringValue, "05")
    }

    func testShippingMethodAsString_whenShippingMethodIsShipToStore_returns06() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .shipToStore
        XCTAssertEqual(request.shippingMethod.stringValue, "06")
    }

    func testShippingMethodAsString_whenShippingMethodIsUnspecified_returnsNil() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .unspecified
        XCTAssertEqual(request.shippingMethod.stringValue, nil)
    }

    func testShippingMethodAsString_whenShippingMethodIsNotSet_returnsNil() {
        let request = BTThreeDSecureRequest()
        XCTAssertEqual(request.shippingMethod.stringValue, nil)
    }

    // MARK: - requestedExemptionTypeAsString

    func testRequestedExemptionTypeAsString_whenRequestedExemptionTypeIsLowValue_returnsLowValue() {
        let request = BTThreeDSecureRequest()
        request.requestedExemptionType = .lowValue
        XCTAssertEqual(request.requestedExemptionType.stringValue, "low_value")
    }

    func testRequestedExemptionTypeAsString_whenRequestedExemptionTypeIsSecureCorporate_returnsSecureCorporate() {
        let request = BTThreeDSecureRequest()
        request.requestedExemptionType = .secureCorporate
        XCTAssertEqual(request.requestedExemptionType.stringValue, "secure_corporate")
    }

    func testRequestedExemptionTypeAsString_whenRequestedExemptionTypeIsTrustedBeneficiary_returnsTrustedBeneficiary() {
        let request = BTThreeDSecureRequest()
        request.requestedExemptionType = .trustedBeneficiary
        XCTAssertEqual(request.requestedExemptionType.stringValue, "trusted_beneficiary")
    }

    func testRequestedExemptionTypeAsString_whenRequestedExemptionTypeIsTransactionRiskAnalysis_returnsTransactionRiskAnalysis() {
        let request = BTThreeDSecureRequest()
        request.requestedExemptionType = .transactionRiskAnalysis
        XCTAssertEqual(request.requestedExemptionType.stringValue, "transaction_risk_analysis")
    }

    func testRequestedExemptionTypeAsString_whenAccountTypeIsUnspecified_returnsNil() {
        let request = BTThreeDSecureRequest()
        request.requestedExemptionType = .unspecified
        XCTAssertEqual(request.requestedExemptionType.stringValue, nil)
    }

    func testRequestedExemptionTypeAsString_whenAccountTypeIsNotSet_returnsNil() {
        let request = BTThreeDSecureRequest()
        XCTAssertEqual(request.requestedExemptionType.stringValue, nil)
    }

    // MARK: - UIType

    func testUIType_whenUITypeNative_setsCardinalUITypeNative() {
        let request = BTThreeDSecureRequest()
        request.uiType = .native
        XCTAssertEqual(request.uiType.cardinalValue, CardinalSessionUIType.native)
    }

    func testUIType_whenUITypeHTML_setsCardinalUITypeHTML() {
        let request = BTThreeDSecureRequest()
        request.uiType = .html
        XCTAssertEqual(request.uiType.cardinalValue, CardinalSessionUIType.HTML)
    }

    func testUIType_whenUITypeBoth_setsCardinalUITypeBoth() {
        let request = BTThreeDSecureRequest()
        request.uiType = .both
        XCTAssertEqual(request.uiType.cardinalValue, CardinalSessionUIType.both)
    }

    // MARK: RenderTypes

    func testRenderTypes_whenAllRenderTypesAreSet_setsAllCardinalRenderTypes() {
        let request = BTThreeDSecureRequest()
        request.renderTypes = [.otp, .singleSelect, .multiSelect, .oob, .html]

        XCTAssertEqual(
            request.renderTypes?.compactMap { $0.cardinalValue },
            [
                CardinalSessionRenderTypeOTP,
                CardinalSessionRenderTypeSingleSelect,
                CardinalSessionRenderTypeMultiSelect,
                CardinalSessionRenderTypeOOB,
                CardinalSessionRenderTypeHTML
            ]
        )
    }
}
