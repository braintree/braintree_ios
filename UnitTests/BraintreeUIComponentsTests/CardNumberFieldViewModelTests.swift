import XCTest
@testable import BraintreeUIComponents

@MainActor
final class CardNumberFieldViewModelTests: XCTestCase {

    private var viewModel: CardNumberFieldViewModel!

    override func setUp() {
        super.setUp()
        viewModel = CardNumberFieldViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - formatted(digits:) — standard grouping (4-4-4-4)

    func testFormatted_emptyDigits_returnsEmpty() {
        XCTAssertEqual(viewModel.formatted(digits: ""), "")
    }

    func testFormatted_partialFirstGroup_noSpaces() {
        XCTAssertEqual(viewModel.formatted(digits: "411"), "411")
    }

    func testFormatted_exactlyOneGroup_noTrailingSpace() {
        XCTAssertEqual(viewModel.formatted(digits: "4111"), "4111")
    }

    func testFormatted_fiveDigits_insertsSpaceAfterFourth() {
        viewModel.updateValue("41111")
        XCTAssertEqual(viewModel.formatted(digits: "41111"), "4111 1")
    }

    func testFormatted_eightDigits_insertsSingleSpace() {
        viewModel.updateValue("41111111")
        XCTAssertEqual(viewModel.formatted(digits: "41111111"), "4111 1111")
    }

    func testFormatted_sixteenDigits_formatsAsFourGroups() {
        viewModel.updateValue("4111111111111111")
        XCTAssertEqual(viewModel.formatted(digits: "4111111111111111"), "4111 1111 1111 1111")
    }

    // MARK: - formatted(digits:) — Amex (4-6-5)

    func testFormatted_amex_fourDigits_noSpaces() {
        viewModel.updateValue("3714")
        XCTAssertEqual(viewModel.formatted(digits: "3714"), "3714")
    }

    func testFormatted_amex_tenDigits_insertsSingleSpace() {
        viewModel.updateValue("3714496353")
        XCTAssertEqual(viewModel.formatted(digits: "3714496353"), "3714 496353")
    }

    func testFormatted_amex_fifteenDigits_formatsAsThreeGroups() {
        viewModel.updateValue("371449635398431")
        XCTAssertEqual(viewModel.formatted(digits: "371449635398431"), "3714 496353 98431")
    }

    // MARK: - formatted(digits:) — Diners Club (4-6-4)

    func testFormatted_dinersClub_fourDigits_noSpaces() {
        viewModel.updateValue("3056")
        XCTAssertEqual(viewModel.formatted(digits: "3056"), "3056")
    }

    func testFormatted_dinersClub_tenDigits_insertsSingleSpace() {
        viewModel.updateValue("3056930902")
        XCTAssertEqual(viewModel.formatted(digits: "3056930902"), "3056 930902")
    }

    func testFormatted_dinersClub_fourteenDigits_formatsAsThreeGroups() {
        viewModel.updateValue("30569309025904")
        XCTAssertEqual(viewModel.formatted(digits: "30569309025904"), "3056 930902 5904")
    }
}
