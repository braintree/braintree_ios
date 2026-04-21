import XCTest
@testable import BraintreeUIComponents

final class CVVFieldValidatorTests: XCTestCase {

    func testValidate_emptyString_returnsRequired() {
        let validator = CVVFieldValidator()
        XCTAssertEqual(validator.validate(""), .invalid("CVV is required"))
    }

    func testValidate_nonNumericCharacters_returnsInvalid() {
        let validator = CVVFieldValidator()
        XCTAssertEqual(validator.validate("12a"), .invalid("CVV is invalid"))
    }

    // MARK: - No known brand (accepts 3 or 4 digits)

    func testValidate_threeDigits_noBrand_returnsValid() {
        let validator = CVVFieldValidator()
        XCTAssertEqual(validator.validate("123"), .valid)
    }

    func testValidate_fourDigits_noBrand_returnsValid() {
        let validator = CVVFieldValidator()
        XCTAssertEqual(validator.validate("1234"), .valid)
    }

    func testValidate_twoDigits_noBrand_returnsValidating() {
        let validator = CVVFieldValidator()
        XCTAssertEqual(validator.validate("12"), .validating)
    }

    // MARK: - Known brand: 3-digit CVV

    func testValidate_threeDigits_expectedLengthThree_returnsValid() {
        let validator = CVVFieldValidator(expectedLength: 3)
        XCTAssertEqual(validator.validate("123"), .valid)
    }

    func testValidate_fourDigits_expectedLengthThree_returnsInvalid() {
        let validator = CVVFieldValidator(expectedLength: 3)
        XCTAssertEqual(validator.validate("1234"), .invalid("CVV is invalid"))
    }

    func testValidate_twoDigits_expectedLengthThree_returnsValidating() {
        let validator = CVVFieldValidator(expectedLength: 3)
        XCTAssertEqual(validator.validate("12"), .validating)
    }

    // MARK: - Known brand: 4-digit CVV (Amex)

    func testValidate_fourDigits_expectedLengthFour_returnsValid() {
        let validator = CVVFieldValidator(expectedLength: 4)
        XCTAssertEqual(validator.validate("1234"), .valid)
    }

    func testValidate_threeDigits_expectedLengthFour_returnsValidating() {
        let validator = CVVFieldValidator(expectedLength: 4)
        XCTAssertEqual(validator.validate("123"), .validating)
    }

    func testValidate_fiveDigits_expectedLengthFour_returnsInvalid() {
        let validator = CVVFieldValidator(expectedLength: 4)
        XCTAssertEqual(validator.validate("12345"), .invalid("CVV is invalid"))
    }
}
