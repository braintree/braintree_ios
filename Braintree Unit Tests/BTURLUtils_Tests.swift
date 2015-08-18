import XCTest

class BTURLUtils_Tests: XCTestCase {

    func testDictionaryForQueryString_hasNullValueWhenKeyOnly() {
        XCTAssertEqual(BTURLUtils.dictionaryForQueryString("foo") as NSDictionary, [
            "foo": NSNull(),
        ])
    }

    func testDictionaryForQueryString_replacesPlusWithSpace() {
        XCTAssertEqual(BTURLUtils.dictionaryForQueryString("foo+bar=baz+yaz") as NSDictionary, [
            "foo bar": "baz yaz"
            ])
    }

    func testDictionaryForQueryString_decodesPercentEncodedCharacters() {
        XCTAssertEqual(BTURLUtils.dictionaryForQueryString("%20%2C=%26") as NSDictionary, [
            " ,": "&"
            ])
    }

    func testDictionaryForQueryString_skipsKeysWithUndecodableCharacters() {
        XCTAssertEqual(BTURLUtils.dictionaryForQueryString("%84") as NSDictionary, [:])
    }

}
