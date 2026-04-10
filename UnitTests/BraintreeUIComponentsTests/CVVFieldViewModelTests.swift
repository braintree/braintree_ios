import XCTest
 @testable import BraintreeUIComponents

 @MainActor
 final class CVVFieldViewModelTests: XCTestCase {

     private var viewModel: CVVFieldViewModel!

     override func setUp() {
         super.setUp()
         viewModel = CVVFieldViewModel()
     }

     override func tearDown() {
         viewModel = nil
         super.tearDown()
     }

     // MARK: - updateValue

     func testUpdateValue_singleDigit_appendsCharacter() {
         viewModel.updateValue("1")
         XCTAssertEqual(viewModel.rawValue, "1")
         XCTAssertEqual(viewModel.characters.count, 1)
     }

     func testUpdateValue_multipleDigits_appendsAllCharacters() {
         viewModel.updateValue("123")
         XCTAssertEqual(viewModel.rawValue, "123")
         XCTAssertEqual(viewModel.characters.count, 3)
     }

     func testUpdateValue_exceedsMaxLength_capsAtFourDigits() {
         viewModel.updateValue("12345")
         XCTAssertEqual(viewModel.rawValue, "1234")
         XCTAssertEqual(viewModel.characters.count, 4)
     }

     func testUpdateValue_nonNumericCharacters_areStripped() {
         viewModel.updateValue("1a2b")
         XCTAssertEqual(viewModel.rawValue, "12")
         XCTAssertEqual(viewModel.characters.count, 2)
     }

     func testUpdateValue_deletion_removesCharactersFromEnd() {
         viewModel.updateValue("123")
         viewModel.updateValue("12")
         XCTAssertEqual(viewModel.rawValue, "12")
         XCTAssertEqual(viewModel.characters.count, 2)
     }

     func testUpdateValue_deleteAll_emptiesCharacters() {
         viewModel.updateValue("123")
         viewModel.updateValue("")
         XCTAssertEqual(viewModel.rawValue, "")
         XCTAssertTrue(viewModel.characters.isEmpty)
     }

     func testUpdateValue_newCharactersStartUnmasked() {
         viewModel.updateValue("1")
         XCTAssertFalse(viewModel.characters[0].isMasked)
     }

     func testUpdateValue_deleteThenRetype_newCharacterIsUnmasked() {
         viewModel.updateValue("12")
         viewModel.updateValue("1")
         viewModel.updateValue("12")
         XCTAssertFalse(viewModel.characters[1].isMasked)
     }
     
     func testUpdateValue_sameLength_differentDigits_updatesCharacters() {
         viewModel.updateValue("123")
         viewModel.updateValue("456")
         XCTAssertEqual(viewModel.rawValue, "456")
         XCTAssertEqual(viewModel.characters.map { $0.value }, ["4", "5", "6"])
     }

     // MARK: - Masking Timer

     func testMaskingTimer_characterMasksAfterDelay() {
         let expectation = expectation(description: "Character masks after 1 second")
         viewModel.updateValue("1")

         DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
             XCTAssertTrue(self.viewModel.characters[0].isMasked)
             expectation.fulfill()
         }

         waitForExpectations(timeout: 2.0)
     }

     func testMaskingTimer_deletedCharacter_doesNotCauseCrash() {
         let expectation = expectation(description: "No crash after delete before timer fires")
         viewModel.updateValue("1")
         viewModel.updateValue("")

         DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
             XCTAssertTrue(self.viewModel.characters.isEmpty)
             expectation.fulfill()
         }

         waitForExpectations(timeout: 2.0)
     }

     func testMaskingTimer_reusedIndex_doesNotMaskNewCharacter() {
         let expectation = expectation(description: "Stale timer does not mask new character at same index")

         viewModel.updateValue("1")

         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
             self.viewModel.updateValue("")
             self.viewModel.updateValue("2")
         }

         DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
             XCTAssertFalse(self.viewModel.characters[0].isMasked)
             expectation.fulfill()
         }

         waitForExpectations(timeout: 2.0)
     }
 }

