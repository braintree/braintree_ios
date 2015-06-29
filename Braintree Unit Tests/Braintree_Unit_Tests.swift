import XCTest
import Braintree

class BTJSON_Tests: XCTestCase {
    func testEmptyJSON() {
        let empty = BTJSON()

        XCTAssertNotNil(empty)

        XCTAssertEqual(empty.asAnyValue() as! NSDictionary, [:])
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
        XCTAssertFalse(empty.isURL)
        XCTAssertFalse(empty.isBOOL)
    }

    func testInitializationFromValue() {
        // TODO
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

        XCTAssertTrue(array[0].isString!)
        XCTAssertEqual(array[0].asString()!, "One")
        XCTAssertEqual(array[1].asString()!, "Two")
        XCTAssertEqual(array[2].asString()!, "Three")

        XCTAssertNil(array[3].asString())
        XCTAssertFalse(array[3].isString!)

        XCTAssertNil(array["hello"].asString())
    }

    func testObjectAccess() {
        let JSON = "{ \"key\": \"value\" }".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)
        
        XCTAssertEqual(obj["key"].asString()!, "value")

        XCTAssertNil(obj["not present"].asString())
        XCTAssertNil(obj[0].asString())

        XCTAssertFalse(obj["not present"].isError!)

        XCTAssertTrue(obj[0].isError!)
    }

    func testParsingError() {
        let JSON = "INVALID JSEqualON".dataUsingEncoding(NSUTF8StringEncoding)!
        let obj = BTJSON(data: JSON)

        XCTAssertTrue(obj.isError)
        XCTAssertEqual((obj.asError()?.domain)!, NSCocoaErrorDomain)
        XCTAssertEqual((obj.asError()?.localizedDescription)!, "The data couldn’t be read because it isn’t in the correct format.")
    }

    func testMultipleErrorsTakesFirst() {
        let JSON = "INVALID JSON".dataUsingEncoding(NSUTF8StringEncoding)!
        let string = BTJSON(data: JSON)

        let error = string.JSONAtIndex(0).JSONForKey("key").JSONAtIndex(0)

        XCTAssertTrue(error.isError)
        XCTAssertEqual((error.asError()?.domain)!, NSCocoaErrorDomain)
        XCTAssertEqual((error.asError()?.localizedDescription)!, "The data couldn’t be read because it isn’t in the correct format.")
    }


    func testNestedObjects() {
        let JSON = "{ \"numbers\": [\"one\", \"two\", { \"tens\": 0, \"ones\": 1 } ], \"truthy\": true }".dataUsingEncoding(NSUTF8StringEncoding)!
        let nested = BTJSON(data: JSON)

        XCTAssertEqual(nested["numbers"][0].asString()!, "one")
        XCTAssertEqual(nested["numbers"][1].asString()!, "two")
        XCTAssertEqual(nested["numbers"][2].JSONForKey("tens").asNumber()!.integerValue, 0)
        XCTAssertEqual(nested["numbers"][2].JSONForKey("ones").asNumber()!.integerValue, 1)
        XCTAssertTrue(nested.JSONForKey("truthy").isTrue)
    }

    func testTrueBoolInterpretation() {
        let JSON = "true".dataUsingEncoding(NSUTF8StringEncoding)!
        let truthy = BTJSON(data: JSON)
        XCTAssertTrue(truthy.isBOOL)
        XCTAssertTrue(truthy.isTrue)
        XCTAssertFalse(truthy.isFalse)
    }

    func testFalseBoolInterpretation() {
        let JSON = "false".dataUsingEncoding(NSUTF8StringEncoding)!
        let truthy = BTJSON(data: JSON)
        XCTAssertTrue(truthy.isBOOL)
        XCTAssertFalse(truthy.isTrue)
        XCTAssertTrue(truthy.isFalse)
    }

//    func testMutation() {
//        let obj = BTJSON(value: "value")
//
//        obj.setValue(NSDictionary())
//
//        XCTAssertEqual(try! obj.asJSON(), "{}".dataUsingEncoding(NSUTF8StringEncoding)!)
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
//
//        obj["array"] = []
//        obj.JSONForKey("array")[0] = "One";
//        obj.JSONForKey("array")[1] = "Two"
//        obj.JSONForKey("array")[2] = "Three"
//        XCTAssertEqual(obj["string"].asString()!, "Hello, World!")
//        XCTAssertEqual(obj["secondString"].asString()!, "Hello, again!")
//        XCTAssertEqual(obj["array"].asArray()!, ["One", "Two", "Three"])
//
////        XCTAssertEqual(try! obj.asJSON(), "{\"string\":\"Hello, World!\"}".dataUsingEncoding(NSUTF8StringEncoding)!)
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
