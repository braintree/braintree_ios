import XCTest
@testable import BraintreeUIComponents

final class ExpirationDateFieldValidatorTests: XCTestCase {

    private let referenceDate: Date = {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: components)!
    }()

    private var validator: ExpirationDateFieldValidator!

    override func setUp() {
        super.setUp()
        validator = ExpirationDateFieldValidator(currentDate: referenceDate)
    }

    override func tearDown() {
        validator = nil
        super.tearDown()
    }

    // MARK: - Helper

    private func mmyy(monthOffset: Int) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(byAdding: .month, value: monthOffset, to: referenceDate)!
        let components = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%02d/%02d", components.month!, components.year! % 100)
    }

    // MARK: - Empty

    func testValidate_emptyString_returnsRequired() {
        XCTAssertEqual(validator.validate(""), .invalid("Expiration date is required"))
    }

    // MARK: - Incomplete (validating)

    func testValidate_monthOnly_returnsValidating() {
        let mm = String(mmyy(monthOffset: 0).prefix(2))
        XCTAssertEqual(validator.validate(mm), .validating)
    }

    func testValidate_noSlash_returnsValidating() {
        let noSlash = mmyy(monthOffset: 0).replacingOccurrences(of: "/", with: "")
        XCTAssertEqual(validator.validate(noSlash), .validating)
    }

    func testValidate_partialYear_returnsValidating() {
        let current = mmyy(monthOffset: 0)
        let mm = String(current.prefix(2))
        let partialYY = String(current.suffix(2).prefix(1))
        XCTAssertEqual(validator.validate("\(mm)/\(partialYY)"), .validating)
    }

    // MARK: - Invalid characters

    func testValidate_nonNumericMonth_returnsInvalid() {
        let yy = String(mmyy(monthOffset: 12).suffix(2))
        XCTAssertEqual(validator.validate("ab/\(yy)"), .invalid("Expiration date is invalid"))
    }

    func testValidate_nonNumericYear_returnsInvalid() {
        let mm = String(mmyy(monthOffset: 0).prefix(2))
        XCTAssertEqual(validator.validate("\(mm)/ab"), .invalid("Expiration date is invalid"))
    }

    // MARK: - Invalid month

    func testValidate_monthZero_returnsInvalid() {
        let yy = String(mmyy(monthOffset: 12).suffix(2))
        XCTAssertEqual(validator.validate("00/\(yy)"), .invalid("Expiration date is invalid"))
    }

    func testValidate_monthThirteen_returnsInvalid() {
        let yy = String(mmyy(monthOffset: 12).suffix(2))
        XCTAssertEqual(validator.validate("13/\(yy)"), .invalid("Expiration date is invalid"))
    }

    // MARK: - Expired

    func testValidate_previousMonth_returnsInvalid() {
        XCTAssertEqual(validator.validate(mmyy(monthOffset: -1)), .invalid("Expiration date is invalid"))
    }

    func testValidate_previousYear_returnsInvalid() {
        XCTAssertEqual(validator.validate(mmyy(monthOffset: -13)), .invalid("Expiration date is invalid"))
    }

    // MARK: - Valid

    func testValidate_currentMonth_returnsValid() {
        XCTAssertEqual(validator.validate(mmyy(monthOffset: 0)), .valid)
    }

    func testValidate_futureMonth_returnsValid() {
        XCTAssertEqual(validator.validate(mmyy(monthOffset: 1)), .valid)
    }

    func testValidate_futureYear_returnsValid() {
        XCTAssertEqual(validator.validate(mmyy(monthOffset: 13)), .valid)
    }

    func testValidate_decemberBoundary_advancesYearCorrectly() {
        let calendar = Calendar(identifier: .gregorian)
        let nextYear = calendar.component(.year, from: referenceDate) + 1
        XCTAssertEqual(validator.validate(String(format: "12/%02d", nextYear % 100)), .valid)
    }

    // MARK: - Far future

    func testValidate_exactlyMaxFutureYears_returnsValid() {
        XCTAssertEqual(validator.validate(mmyy(monthOffset: 20 * 12 - 1)), .valid)
    }

    func testValidate_beyondMaxFutureYears_returnsInvalid() {
        XCTAssertEqual(validator.validate(mmyy(monthOffset: 20 * 12)), .invalid("Expiration date is invalid"))
    }
}
