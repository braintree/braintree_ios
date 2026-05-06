import XCTest
@testable import BraintreeUIComponents

final class ExpirationDateFieldValidatorTests: XCTestCase {
                                                                                                                                                         
    // Fixed reference date: May 2026
    private let may2026 = DateComponents(calendar: Calendar(identifier: .gregorian), year: 2026, month: 5, day: 1).date!
                                                                                                                                                           
    private var validator: ExpirationDateFieldValidator!
                                                                                                                                                           
    override func setUp() {
        super.setUp()
        validator = ExpirationDateFieldValidator(currentDate: may2026)
    }
                                                                                                                                                           
    override func tearDown() {
        validator = nil
        super.tearDown()
    }
                                                                                                                                                           
    // MARK: - Empty
                                                                                                                                                           
    func testValidate_emptyString_returnsRequired() {
        XCTAssertEqual(validator.validate(""), .invalid("Expiration date is required"))
    }

    // MARK: - Incomplete (validating)
                                                          
    func testValidate_monthOnly_returnsValidating() {
        XCTAssertEqual(validator.validate("05"), .validating)
    }
                                                          
    func testValidate_noSlash_returnsValidating() {
        XCTAssertEqual(validator.validate("0526"), .validating)
    }
                                                          
    func testValidate_partialYear_returnsValidating() {
        XCTAssertEqual(validator.validate("05/2"), .validating)
    }
    
    // MARK: - Invalid characters
                                                                                                                                                           
    func testValidate_nonNumericMonth_returnsValidating() {
        XCTAssertEqual(validator.validate("ab/26"), .invalid("Expiration date is invalid"))
    }
                                                          
    func testValidate_nonNumericYear_returnsValidating() {
        XCTAssertEqual(validator.validate("05/ab"), .invalid("Expiration date is invalid"))
    }

    // MARK: - Invalid month
                                                          
    func testValidate_monthZero_returnsInvalid() {
        XCTAssertEqual(validator.validate("00/27"), .invalid("Expiration date is invalid"))
    }
                                                          
    func testValidate_monthThirteen_returnsInvalid() {
        XCTAssertEqual(validator.validate("13/27"), .invalid("Expiration date is invalid"))
    }
                                                          
    // MARK: - Expired

    func testValidate_previousMonth_returnsInvalid() {
        XCTAssertEqual(validator.validate("04/26"), .invalid("Expiration date is invalid"))
    }
 
    func testValidate_previousYear_returnsInvalid() {
        XCTAssertEqual(validator.validate("12/25"), .invalid("Expiration date is invalid"))
    }
 
    // MARK: - Valid
                                                          
    func testValidate_currentMonth_returnsValid() {
        XCTAssertEqual(validator.validate("05/26"), .valid)
    }
                                                                                                                                                           
    func testValidate_futureMonth_returnsValid() {
        XCTAssertEqual(validator.validate("06/26"), .valid)
    }
                                                          
    func testValidate_futureYear_returnsValid() {
        XCTAssertEqual(validator.validate("01/27"), .valid)
    }
 
    func testValidate_decemberBoundary_advancesYearCorrectly() {
        XCTAssertEqual(validator.validate("12/26"), .valid)
    }
                                                                                                                                                           
    // MARK: - Far future
                                                          
    func testValidate_exactlyMaxFutureYears_returnsValid() {
        XCTAssertEqual(validator.validate("04/46"), .valid)
    }
                                                                                                                                                           
    func testValidate_beyondMaxFutureYears_returnsInvalid() {
        XCTAssertEqual(validator.validate("05/46"), .invalid("Expiration date is invalid"))
    }
}
