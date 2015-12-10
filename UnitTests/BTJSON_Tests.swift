import XCTest

class BTJSON_Tests: XCTestCase {
    func testEmptyJSON() {
        let empty = BTJSON()

        XCTAssertNotNil(empty)

        XCTAssertTrue(empty.isObject)

        XCTAssertNil(empty.asString())
        XCTAssertNil(empty.asArray())
        XCTAssertNil(empty.asNumber())
        XCTAssertNil(empty.asURL())
        XCTAssertNil(empty.asStringArray())
        XCTAssertNil(empty.asError())

        XCTAssertFalse(empty.isString)
        XCTAssertFalse(empty.isNumber)
        XCTAssertFalse(empty.isArray)
        XCTAssertFalse(empty.isTrue)
        XCTAssertFalse(empty.isFalse)
        XCTAssertFalse(empty.isNull)
    }

    func testInitializationFromValue() {
        let string = BTJSON(value: "")
        XCTAssertTrue(string.isString)

        let truth = BTJSON(value: true)
        XCTAssertTrue(truth.isTrue)

        let falsehood = BTJSON(value: false)
        XCTAssertTrue(falsehood.isFalse)

        let number = BTJSON(value: 42)
        XCTAssertTrue(number.isNumber)

        let ary = BTJSON(value: [1,2,3])
        XCTAssertTrue(ary.isArray)

        let obj = BTJSON(value: ["one": 1, "two": 2])
        XCTAssertTrue(obj.isObject)

        let null = BTJSON(value: NSNull())
        XCTAssertTrue(null.isNull)
    }

    func testInitializationFromEmptyData() {
        let emptyDataJSON = BTJSON(data: NSData())
        XCTAssertTrue(emptyDataJSON.isError)
    }

    func testStringJSON() {
        let JSON = "\"Hello, JSON!\"".dataUsingEncoding(NSUTF8StringEncoding)!
        let string = BTJSON(data: JSON)

        XCTAssertTrue(string.isString)
        XCTAssertEqual(string.asString()!, "Hello, JSON!")
    }

    func testArrayJSON() {
        let JSON = "[\"One\", \"Two\", \"Three\"]".dataUsingEncoding(NSUTF8StringEncoding)!
        let array = BTJSON(data: JSON)

        XCTAssertTrue(array.isArray)
        XCTAssertEqual(array.asArray()!, ["One", "Two", "Three"])
    }

    func testArrayAccess() {
        let JSON = "[\"One\", \"Two\", \"Three\"]".dataUsingEncoding(NSUTF8StringEncoding)!
        let array = BTJSON(data: JSON)

        XCTAssertTrue(array[0].isString)
        XCTAssertEqual(array[0].asString()!, "One")
        XCTAssertEqual(array[1].asString()!, "Two")
        XCTAssertEqual(array[2].asString()!, "Three")

        XCTAssertNil(array[3].asString())
        XCTAssertFalse(array[3].isString)

        XCTAssertNil(array["hello"].asString())
    }

    func testObjectAccess() {
        let JSON = "{ \"key\": \"value\" }".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)
        
        XCTAssertEqual(obj["key"].asString()!, "value")

        XCTAssertNil(obj["not present"].asString())
        XCTAssertNil(obj[0].asString())

        XCTAssertFalse(obj["not present"].isError as Bool)

        XCTAssertTrue(obj[0].isError)
    }

    func testParsingError() {
        let JSON = "INVALID JSON".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)

        XCTAssertTrue(obj.isError)
        XCTAssertEqual((obj.asError()?.domain)!, NSCocoaErrorDomain)
    }

    func testMultipleErrorsTakesFirst() {
        let JSON = "INVALID JSON".dataUsingEncoding(NSUTF8StringEncoding)!
        let string = BTJSON(data: JSON)

        let error = string[0]["key"][0]

        XCTAssertTrue(error.isError as Bool)
        XCTAssertEqual((error.asError()?.domain)!, NSCocoaErrorDomain)
    }

    func testNestedObjects() {
        let JSON = "{ \"numbers\": [\"one\", \"two\", { \"tens\": 0, \"ones\": 1 } ], \"truthy\": true }".dataUsingEncoding(NSUTF8StringEncoding)!
        let nested = BTJSON(data: JSON)

        XCTAssertEqual(nested["numbers"][0].asString()!, "one")
        XCTAssertEqual(nested["numbers"][1].asString()!, "two")
        XCTAssertEqual(nested["numbers"][2]["tens"].asNumber()!, NSDecimalNumber.zero())
        XCTAssertEqual(nested["numbers"][2]["ones"].asNumber()!, NSDecimalNumber.one())
        XCTAssertTrue(nested["truthy"].isTrue as Bool)
    }

    func testTrueBoolInterpretation() {
        let JSON = "true".dataUsingEncoding(NSUTF8StringEncoding)!
        let truthy = BTJSON(data: JSON)
        XCTAssertTrue(truthy.isTrue)
        XCTAssertFalse(truthy.isFalse)
    }

    func testFalseBoolInterpretation() {
        let JSON = "false".dataUsingEncoding(NSUTF8StringEncoding)!
        let truthy = BTJSON(data: JSON)
        XCTAssertFalse(truthy.isTrue)
        XCTAssertTrue(truthy.isFalse)
    }

    func testAsURL() {
        let JSON = "{ \"url\": \"http://example.com\" }".dataUsingEncoding(NSUTF8StringEncoding)!
        let url = BTJSON(data: JSON)
        XCTAssertEqual(url["url"].asURL()!, NSURL(string: "http://example.com")!)
    }

    func testAsURLForInvalidValue() {
        let JSON = "{ \"url\": 42 }".dataUsingEncoding(NSUTF8StringEncoding)!
        let url = BTJSON(data: JSON)
        XCTAssertNil(url["url"].asURL())
    }

    func testAsStringArray() {
        let JSON = "[\"one\", \"two\", \"three\"]".dataUsingEncoding(NSUTF8StringEncoding)!
        let stringArray = BTJSON(data: JSON)
        XCTAssertEqual(stringArray.asStringArray()!, ["one", "two", "three"])
    }

    func testAsStringArrayForInvalidValue() {
        let JSON = "[1, 2, false]".dataUsingEncoding(NSUTF8StringEncoding)!
        let stringArray = BTJSON(data: JSON)
        XCTAssertNil(stringArray.asStringArray())
    }

    func testAsStringArrayForHeterogeneousValue() {
        let JSON = "[\"string\", false]".dataUsingEncoding(NSUTF8StringEncoding)!
        let stringArray = BTJSON(data: JSON)
        XCTAssertNil(stringArray.asStringArray())
    }

    func testAsStringArrayForEmptyArray() {
        let JSON = "[]".dataUsingEncoding(NSUTF8StringEncoding)!
        let stringArray = BTJSON(data: JSON)
        XCTAssertEqual(stringArray.asStringArray()!, [])
    }

    func testAsDictionary() {
        let JSON = "{ \"key\": \"value\" }".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)

        XCTAssertEqual(obj.asDictionary()!, ["key":"value"] as NSDictionary)
    }

    func testAsDictionaryInvalidValue() {
        let JSON = "[]".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)

        XCTAssertNil(obj.asDictionary())
    }

    func testAsIntegerOrZero() {
        let cases = [
            "1": 1,
            "1.2": 1,
            "1.5": 1,
            "1.9": 1,
            "-4": -4,
            "0": 0,
            "\"Hello\"": 0,
        ]
        for (k,v) in cases {
            let JSON = BTJSON(data: k.dataUsingEncoding(NSUTF8StringEncoding)!)
            XCTAssertEqual(JSON.asIntegerOrZero(), v)
        }
    }

    func testAsEnumOrDefault() {
        let JSON = "\"enum one\"".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)

        XCTAssertEqual(obj.asEnum(["enum one" : 1], orDefault: 0), 1)
    }

    func testAsEnumOrDefaultWhenMappingNotPresentReturnsDefault() {
        let JSON = "\"enum one\"".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)

        XCTAssertEqual(obj.asEnum(["enum two" : 2], orDefault: 1000), 1000)
    }

    func testAsEnumOrDefaultWhenMapValueIsNotNumberReturnsDefault() {
        let JSON = "\"enum one\"".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)

        XCTAssertEqual(obj.asEnum(["enum one" : "one"], orDefault: 1000), 1000)
    }

    func testIsNull() {
        let JSON = "null".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)

        XCTAssertTrue(obj.isNull);
    }

    func testIsObject() {
        let JSON = "{}".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)

        XCTAssertTrue(obj.isObject);
    }

    func testIsObjectForNonObject() {
        let JSON = "[]".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)

        XCTAssertFalse(obj.isObject);
    }

    func testLargerMixedJSONWithEmoji() {
        let JSON = ("{" +
            "\"aString\": \"Hello, JSON 😍!\"," +
            "\"anArray\": [1, 2, 3 ]," +
            "\"aSetOfValues\": [\"a\", \"b\", \"c\"]," +
            "\"aSetWithDuplicates\": [\"a\", \"a\", \"b\", \"b\" ]," +
            "\"aLookupDictionary\": {" +
            "\"foo\": { \"definition\": \"A meaningless word\"," +
            "\"letterCount\": 3," +
            "\"meaningful\": false }" +
            "}," +
            "\"aURL\": \"https://test.example.com:1234/path\"," +
            "\"anInvalidURL\": \":™£¢://://://???!!!\"," +
            "\"aTrue\": true," +
            "\"aFalse\": false" +
            "}").dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)

        XCTAssertEqual(obj["aString"].asString(), "Hello, JSON 😍!")
        XCTAssertNil(obj["notAString"].asString()) // nil for absent keys
        XCTAssertNil(obj["anArray"].asString()) // nil for invalid values
        XCTAssertEqual(obj["anArray"].asArray()!, [1, 2, 3])
        XCTAssertNil(obj["notAnArray"].asArray()) // nil for absent keys
        XCTAssertNil(obj["aString"].asArray()) // nil for invalid values
        // sets can be parsed as arrays:
        XCTAssertEqual(obj["aSetOfValues"].asArray()!, ["a", "b", "c"])
        XCTAssertEqual(obj["aSetWithDuplicates"].asArray()!, ["a", "a", "b", "b"])
        let dictionary = obj["aLookupDictionary"].asDictionary()!
        let foo = dictionary["foo"]! as! Dictionary<String, AnyObject>
        XCTAssertEqual((foo["definition"] as! String), "A meaningless word")
        let letterCount = foo["letterCount"] as! NSNumber
        XCTAssertEqual(letterCount, 3)
        XCTAssertFalse(foo["meaningful"] as! Bool)
        XCTAssertNil(obj["notADictionary"].asDictionary())
        XCTAssertNil(obj["aString"].asDictionary())
        XCTAssertEqual(obj["aURL"].asURL(), NSURL(string: "https://test.example.com:1234/path"))
        XCTAssertNil(obj["notAURL"].asURL())
        XCTAssertNil(obj["aString"].asURL())
        XCTAssertNil(obj["anInvalidURL"].asURL()) // nil for invalid URLs
        // nested resources:
        let btJson = obj["aLookupDictionary"]
        XCTAssertEqual(btJson["foo"]["definition"].asString(), "A meaningless word")
        XCTAssert(btJson["aString"]["anything"].isError as Bool) // indicates error when value type is invalid
    }
}
