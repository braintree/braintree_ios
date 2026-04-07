import XCTest
@testable import BraintreeUIComponents

final class CardNumberFieldValidatorTests: XCTestCase {

    private var validator: CardNumberValidator!

    override func setUp() {
        super.setUp()
        validator = CardNumberValidator()
    }

    override func tearDown() {
        validator = nil
        super.tearDown()
    }

    // MARK: - Empty Input

    func testValidate_emptyString_returnsInvalid() {
        XCTAssertEqual(validator.validate(""), .invalid("Card number is required"))
    }

    // MARK: - Non-Numeric Characters

    func testValidate_nonNumericCharacters_returnsInvalid() {
        XCTAssertEqual(validator.validate("4111abcd11111111"), .invalid("Card number must contain numbers only"))
    }

    func testValidate_spacesAllowed_doesNotReturnNonNumericError() {
        let result = validator.validate("4111 1111 1111 1111")
        XCTAssertNotEqual(result, .invalid("Card number must contain numbers only"))
    }

    // MARK: - Luhn Validation

    func testValidate_validLuhnVisa_returnsValid() {
        XCTAssertEqual(validator.validate("4111111111111111"), .valid)
    }

    func testValidate_invalidLuhn_returnsInvalid() {
        XCTAssertEqual(validator.validate("4111111111111112"), .invalid("Invalid card number"))
    }

    // MARK: - Brand Detection

    func testDetectBrand_visaPrefix_returnsVisa() {
        XCTAssertEqual(validator.detectBrand(from: "4111111111111111"), .visa)
    }

    func testDetectBrand_mastercardPrefix51_returnsMastercard() {
        XCTAssertEqual(validator.detectBrand(from: "5111111111111111"), .mastercard)
    }

    func testDetectBrand_mastercardPrefix2221_returnsMastercard() {
        XCTAssertEqual(validator.detectBrand(from: "2221000000000000"), .mastercard)
    }

    func testDetectBrand_amexPrefix34_returnsAmex() {
        XCTAssertEqual(validator.detectBrand(from: "341111111111111"), .amex)
    }

    func testDetectBrand_amexPrefix37_returnsAmex() {
        XCTAssertEqual(validator.detectBrand(from: "371111111111111"), .amex)
    }

    func testDetectBrand_discover6011_returnsDiscover() {
        XCTAssertEqual(validator.detectBrand(from: "6011111111111111"), .discover)
    }

    func testDetectBrand_discover65_returnsDiscover() {
        XCTAssertEqual(validator.detectBrand(from: "6500000000000000"), .discover)
    }

    func testDetectBrand_discover644_returnsDiscover() {
        XCTAssertEqual(validator.detectBrand(from: "6441000000000000"), .discover)
    }

    func testDetectBrand_discover622_returnsDiscover() {
        XCTAssertEqual(validator.detectBrand(from: "6221260000000000"), .discover)
    }

    func testDetectBrand_unionPay62_notInDiscoverRange_returnsUnionPay() {
        XCTAssertEqual(validator.detectBrand(from: "6200000000000000"), .unionPay)
    }

    func testDetectBrand_jcb_returnsJCB() {
        XCTAssertEqual(validator.detectBrand(from: "3528000000000000"), .jcb)
    }

    func testDetectBrand_dinersClub36_returnsDinersClub() {
        XCTAssertEqual(validator.detectBrand(from: "36111111111111"), .dinersClub)
    }

    func testDetectBrand_dinersClub300_returnsDinersClub() {
        XCTAssertEqual(validator.detectBrand(from: "30011111111111"), .dinersClub)
    }

    func testDetectBrand_maestroRelaxed_returnsMaestro() {
        XCTAssertEqual(validator.detectBrand(from: "6304000000000000"), .maestro)
    }

    func testDetectBrand_unknown_returnsUnknown() {
        XCTAssertEqual(validator.detectBrand(from: "9999999999999999"), .unknown)
    }

    // MARK: - Length Validation

    func testValidate_amex15Digits_returnsValid() {
        XCTAssertEqual(validator.validate("378282246310005"), .valid)
    }

    func testValidate_amex16Digits_returnsInvalid() {
        XCTAssertEqual(validator.validate("3782822463100055"), .invalid("Invalid card number length"))
    }

    func testValidate_dinersClub14Digits_returnsValid() {
        XCTAssertEqual(validator.validate("30569309025904"), .valid)
    }

    func testValidate_cardTooLong_returnsInvalid() {
        XCTAssertEqual(validator.validate("41111111111111111111"), .invalid("Card number is too long"))
    }

    func testValidate_incompleteNumber_returnsValid() {
        // Should not show invalid while still typing
        XCTAssertEqual(validator.validate("4111"), .valid)
    }

    // MARK: - Known Test Card Numbers

    func testValidate_knownVisaTestCard_returnsValid() {
        XCTAssertEqual(validator.validate("4111111111111111"), .valid)
    }

    func testValidate_knownMastercardTestCard_returnsValid() {
        XCTAssertEqual(validator.validate("5500005555555559"), .valid)
    }

    func testValidate_knownAmexTestCard_returnsValid() {
        XCTAssertEqual(validator.validate("378282246310005"), .valid)
    }

    func testValidate_knownDiscoverTestCard_returnsValid() {
        XCTAssertEqual(validator.validate("6011111111111117"), .valid)
    }
}
