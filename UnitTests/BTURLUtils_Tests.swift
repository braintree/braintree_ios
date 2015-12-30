import XCTest

class BTURLUtils_Tests: XCTestCase {

    // MARK: - dictionaryForQueryString:

    func testDictionaryForQueryString_whenQueryStringIsNil_returnsEmptyDictionary() {
        XCTAssertEqual(BTURLUtils.dictionaryForQueryString(nil) as NSDictionary, [:])
    }

    func testDictionaryForQueryString_whenQueryStringIsEmpty_returnsEmptyDictionary() {
        XCTAssertEqual(BTURLUtils.dictionaryForQueryString("") as NSDictionary, [:])
    }

    func testDictionaryForQueryString_whenQueryStringIsHasItems_returnsDictionaryContainingItems() {
        XCTAssertEqual(BTURLUtils.dictionaryForQueryString("foo=bar&baz=quux") as NSDictionary, [
            "foo": "bar",
            "baz": "quux"])
    }

    func testDictionaryForQueryString_hasNSNullValueWhenKeyOnly() {
        XCTAssertEqual(BTURLUtils.dictionaryForQueryString("foo") as NSDictionary, [
            "foo": NSNull(),
        ])
    }

    func testDictionaryForQueryString_whenKeyIsEmpty_hasEmptyStringForKey() {
        XCTAssertEqual(BTURLUtils.dictionaryForQueryString("&=asdf&") as NSDictionary, [
            "": "asdf"
            ])
    }

    func testDictionaryForQueryString_withDuplicateKeys_usesRightMostValue() {
        XCTAssertEqual(BTURLUtils.dictionaryForQueryString("key=value1&key=value2") as NSDictionary, [
            "key": "value2"
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

    // MARK: - URLfromURL:withAppendedQueryDictionary:

    func testURLWithAppendedQueryDictionary_appendsDictionaryAsQueryStringToURL() {
        let url = NSURL(string: "http://example.com:80/path/to/file")!

        let appendedURL = BTURLUtils.URLfromURL(url, withAppendedQueryDictionary: ["key": "value"])

        XCTAssertEqual(appendedURL, NSURL(string: "http://example.com:80/path/to/file?key=value"))
    }

    func testURLWithAppendedQueryDictionary_acceptsNilDictionaries() {
        let url = NSURL(string: "http://example.com")!

        let appendedURL = BTURLUtils.URLfromURL(url, withAppendedQueryDictionary: nil)

        XCTAssertEqual(appendedURL, NSURL(string: "http://example.com?"))
    }

    func testURLWithAppendedQueryDictionary_whenDictionaryHasKeyValuePairsWithSpecialCharacters_percentEscapesThem() {
        let url = NSURL(string: "http://example.com")!

        let appendedURL = BTURLUtils.URLfromURL(url, withAppendedQueryDictionary: ["space ": "sym&bol="])

        XCTAssertEqual(appendedURL, NSURL(string: "http://example.com?space%20=sym%26bol%3D"))
    }

    func testURLWithAppendedQueryDictionary_whenURLIsNil_returnsNil() {
        XCTAssertNil(BTURLUtils.URLfromURL(nil, withAppendedQueryDictionary: [:]))
    }

    func testURLWithAppendedQueryDictionary_whenURLIsRelative_returnsExpectedURL() {
        let url = NSURL(string: "/relative/path")!

        let appendedURL = BTURLUtils.URLfromURL(url, withAppendedQueryDictionary: ["key": "value"])

        XCTAssertEqual(appendedURL, NSURL(string: "/relative/path?key=value"))
    }

}
