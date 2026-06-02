import XCTest
@testable import BraintreeUIComponents

@MainActor
final class ExpirationDateFieldViewModelTests: XCTestCase {

    private var viewModel: ExpirationDateFieldViewModel!

    override func setUp() {
        super.setUp()
        let fixedDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        viewModel = ExpirationDateFieldViewModel(validator: ExpirationDateFieldValidator(currentDate: fixedDate))
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - expirationMonth

    func testExpirationMonth_withValidFormattedValue_returnsMonthMonthAndYear() {
        viewModel.updateValue("12/26")
        XCTAssertEqual(viewModel.expirationMonth, "12")
        XCTAssertEqual(viewModel.expirationYear, "2026")
        XCTAssertEqual(viewModel.value, "12/26")
        XCTAssertEqual(viewModel.validationState, .valid)
        XCTAssertTrue(viewModel.shouldAutoAdvance)
    }

    func testExpirationMonth_withSingleDigitMonth_returnsMonthAndYear() {
        viewModel.updateValue("01/26")
        XCTAssertEqual(viewModel.expirationMonth, "01")
        XCTAssertEqual(viewModel.expirationYear, "2026")
        XCTAssertEqual(viewModel.validationState, .valid)
        XCTAssertTrue(viewModel.shouldAutoAdvance)
    }

    func testExpirationMonth_withEmptyValue_returnsEmptyString() {
        XCTAssertEqual(viewModel.expirationMonth, "")
        XCTAssertEqual(viewModel.expirationYear, "")
        // we consider empty form to be valid in order to avoid warning when first moving to field
        XCTAssertEqual(viewModel.validationState, .valid)
        XCTAssertFalse(viewModel.shouldAutoAdvance)
    }

    func testExpirationMonth_withNoSlash_returnsFullValue() {
        viewModel.updateValue("12")
        XCTAssertEqual(viewModel.expirationMonth, "12")
        XCTAssertEqual(viewModel.expirationYear, "")
        XCTAssertEqual(viewModel.validationState, .validating)
        XCTAssertFalse(viewModel.shouldAutoAdvance)
    }
}
