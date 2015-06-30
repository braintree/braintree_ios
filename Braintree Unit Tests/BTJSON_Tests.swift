import XCTest
import Braintree

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

        XCTAssertFalse(obj["not present"].isError)

        XCTAssertTrue(obj[0].isError)
    }

    func testParsingError() {
        let JSON = "INVALID JSON".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)

        XCTAssertTrue(obj.isError)
        XCTAssertEqual((obj.asError()?.domain)!, NSCocoaErrorDomain)
        XCTAssertEqual((obj.asError()?.localizedDescription)!, "The data couldn’t be read because it isn’t in the correct format.")
    }

    func testMultipleErrorsTakesFirst() {
        let JSON = "INVALID JSON".dataUsingEncoding(NSUTF8StringEncoding)!
        let string = BTJSON(data: JSON)

        let error = string[0]["key"][0]

        XCTAssertTrue(error.isError)
        XCTAssertEqual((error.asError()?.domain)!, NSCocoaErrorDomain)
        XCTAssertEqual((error.asError()?.localizedDescription)!, "The data couldn’t be read because it isn’t in the correct format.")
    }


    func testNestedObjects() {
        let JSON = "{ \"numbers\": [\"one\", \"two\", { \"tens\": 0, \"ones\": 1 } ], \"truthy\": true }".dataUsingEncoding(NSUTF8StringEncoding)!
        let nested = BTJSON(data: JSON)

        XCTAssertEqual(nested["numbers"][0].asString()!, "one")
        XCTAssertEqual(nested["numbers"][1].asString()!, "two")
        XCTAssertEqual(nested["numbers"][2]["tens"].asNumber()!, NSDecimalNumber.zero())
        XCTAssertEqual(nested["numbers"][2]["ones"].asNumber()!, NSDecimalNumber.one())
        XCTAssertTrue(nested["truthy"].isTrue)
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


//    func testMutation() {
//        var obj = BTJSON()
//
//        obj["string"] = "Hello, World!"
//        XCTAssertEqual(obj["string"].asString()!, "Hello, World!")
//
//        obj["string"] = "Goodbye, World!"
//        XCTAssertEqual(obj["string"].asString()!, "Goodbye, World!")
//
//        obj["secondString"] = "Hello, again!"
//        XCTAssertEqual(obj["string"].asString()!, "Goodbye, World!")
//        XCTAssertEqual(obj["secondString"].asString()!, "Hello, again!")

//        obj["array"] = []
//        obj.JSONForKey("array")[0] = "One";
//        obj.JSONForKey("array")[1] = "Two"
//        obj.JSONForKey("array")[2] = "Three"
//        XCTAssertEqual(obj["string"].asString()!, "Hello, World!")
//        XCTAssertEqual(obj["secondString"].asString()!, "Hello, again!")
//        XCTAssertEqual(obj["array"].asArray()!, ["One", "Two", "Three"])

//        XCTAssertEqual(try! obj.asJSON(), "{\"string\":\"Hello, World!\"}".dataUsingEncoding(NSUTF8StringEncoding)!)
//    }

//    func testSerializationAsJSON() {
//        let JSON = "{ \"key\": \"value\" }".dataUsingEncoding(NSUTF8StringEncoding)!
//        let obj = BTJSON(data: JSON)
//
////        obj["numbers"] = [1,2,"three"]
//
//        let serializedJSON = try! obj.asJSON()
//        XCTAssertEqual(serializedJSON, "{ \"key\": \"value\", \"numbers\": [1, 2, \"three\"] }".dataUsingEncoding(NSUTF8StringEncoding)!)
//
//        let prettySerializedJSON = try! obj.asPrettyJSON()
//        XCTAssertEqual(prettySerializedJSON, "{\n\t\"key\" : \"value\",\n\t\"numbers\" : [1, 2, \"three\"]\n}")
//    }
}
