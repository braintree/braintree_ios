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
        let emptyDataJSON = BTJSON(data: Data())
        XCTAssertTrue(emptyDataJSON.isError)
    }

    func testStringJSON() {
        let JSON = "\"Hello, JSON!\"".data(using: String.Encoding.utf8)!
        let string = BTJSON(data: JSON)

        XCTAssertTrue(string.isString)
        XCTAssertEqual(string.asString()!, "Hello, JSON!")
    }

    func testArrayJSON() {
        let jsonString =
            """
            [
                { "thing1" : "thing1" },
                { "thing2" : "thing2" },
                { "thing3" : "thing3" }
            ]
            """
        let array = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)

        XCTAssertTrue(array.isArray)
        XCTAssertEqual(array.asArray()?.count, 3)
        XCTAssertEqual(array.asArray()?.first?["thing1"].asString(), "thing1")
    }

    func testArrayAccess() {
        let JSON = "[\"One\", \"Two\", \"Three\"]".data(using: String.Encoding.utf8)!
        let array = BTJSON(data: JSON)

        XCTAssertTrue(array[0].isString)
        XCTAssertEqual(array[0].asString()!, "One")
        XCTAssertEqual(array[1].asString()!, "Two")
        XCTAssertEqual(array[2].asString()!, "Three")

        XCTAssertNil(array[3].asString())
        XCTAssertFalse(array[3].isString)

        XCTAssertNil((array["hello"] as AnyObject).asString())
    }

    func testObjectAccess() {
        let JSON = "{ \"key\": \"value\" }".data(using: String.Encoding.utf8)!
        let obj = BTJSON(data: JSON)
        
        XCTAssertEqual((obj["key"] as AnyObject).asString()!, "value")

        XCTAssertNil((obj["not present"] as AnyObject).asString())
        XCTAssertNil(obj[0].asString())

        XCTAssertFalse((obj["not present"] as AnyObject).isError as Bool)

        XCTAssertTrue(obj[0].isError)
    }

    func testParsingError() {
        let JSON = "INVALID JSON".data(using: String.Encoding.utf8)!
        let obj = BTJSON(data: JSON)

        XCTAssertTrue(obj.isError)
        guard let error = obj.asError() as NSError? else {return}
        XCTAssertEqual(error.domain, NSCocoaErrorDomain)
    }

    func testMultipleErrorsTakesFirst() {
        let JSON = "INVALID JSON".data(using: String.Encoding.utf8)!
        let string = BTJSON(data: JSON)
        
        let error = ((string[0])["key"][0])

        XCTAssertTrue(error.isError as Bool)
        guard let err = error.asError() as NSError? else {return}
        XCTAssertEqual(err.domain, NSCocoaErrorDomain)
    }

    func testNestedObjects() {
        let jsonString =
            """
            {
              "numbers": [
                "one",
                "two",
                {
                  "tens": 0,
                  "ones": 1
                }
              ],
              "truthy": true
            }
            """
        
        let nested = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)

        XCTAssertEqual((nested["numbers"])[0].asString()!, "one")
        XCTAssertEqual((nested["numbers"])[1].asString()!, "two")
        XCTAssertEqual((nested["numbers"])[2]["tens"].asNumber()!, NSDecimalNumber.zero)
        XCTAssertEqual((nested["numbers"])[2]["ones"].asNumber()!, NSDecimalNumber.one)
        XCTAssertTrue((nested["truthy"]).isTrue as Bool)
    }

    func testTrueBoolInterpretation() {
        let JSON = "true".data(using: String.Encoding.utf8)!
        let truthy = BTJSON(data: JSON)
        XCTAssertTrue(truthy.isTrue)
        XCTAssertFalse(truthy.isFalse)
    }

    func testFalseBoolInterpretation() {
        let JSON = "false".data(using: String.Encoding.utf8)!
        let truthy = BTJSON(data: JSON)
        XCTAssertFalse(truthy.isTrue)
        XCTAssertTrue(truthy.isFalse)
    }

    func testAsURL() {
        let JSON = "{ \"url\": \"http://example.com\" }".data(using: String.Encoding.utf8)!
        let url = BTJSON(data: JSON)
        XCTAssertEqual((url["url"] as AnyObject).asURL()!, URL(string: "http://example.com")!)
    }

    func testAsURLForInvalidValue() {
        let JSON = "{ \"url\": 42 }".data(using: String.Encoding.utf8)!
        let url = BTJSON(data: JSON)
        XCTAssertNil((url["url"] as AnyObject).asURL())
    }

    func testAsStringArray() {
        let JSON = "[\"one\", \"two\", \"three\"]".data(using: String.Encoding.utf8)!
        let stringArray = BTJSON(data: JSON)
        XCTAssertEqual(stringArray.asStringArray()!, ["one", "two", "three"])
    }

    func testAsStringArrayForInvalidValue() {
        let JSON = "[1, 2, false]".data(using: String.Encoding.utf8)!
        let stringArray = BTJSON(data: JSON)
        XCTAssertNil(stringArray.asStringArray())
    }

    func testAsStringArrayForHeterogeneousValue() {
        let JSON = "[\"string\", false]".data(using: String.Encoding.utf8)!
        let stringArray = BTJSON(data: JSON)
        XCTAssertNil(stringArray.asStringArray())
    }

    func testAsStringArrayForEmptyArray() {
        let JSON = "[]".data(using: String.Encoding.utf8)!
        let stringArray = BTJSON(data: JSON)
        XCTAssertEqual(stringArray.asStringArray()!, [])
    }

    func testAsDictionary() {
        let JSON = "{ \"key\": \"value\" }".data(using: String.Encoding.utf8)!
        let obj = BTJSON(data: JSON)

        XCTAssertEqual((obj.asDictionary()! as AnyObject) as! NSDictionary, ["key":"value"] as NSDictionary)
    }

    func testAsDictionaryInvalidValue() {
        let JSON = "[]".data(using: String.Encoding.utf8)!
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
            let JSON = BTJSON(data: k.data(using: String.Encoding.utf8)!)
            XCTAssertEqual(JSON.asIntegerOrZero(), v)
        }
    }

    func testAsEnumOrDefault() {
        let JSON = "\"enum one\"".data(using: String.Encoding.utf8)!
        let obj = BTJSON(data: JSON)

        XCTAssertEqual(obj.asEnum(["enum one" : 1], orDefault: 0), 1)
    }

    func testAsEnumOrDefaultWhenMappingNotPresentReturnsDefault() {
        let JSON = "\"enum one\"".data(using: String.Encoding.utf8)!
        let obj = BTJSON(data: JSON)

        XCTAssertEqual(obj.asEnum(["enum two" : 2], orDefault: 1000), 1000)
    }

    func testAsEnumOrDefaultWhenMapValueIsNotNumberReturnsDefault() {
        let JSON = "\"enum one\"".data(using: String.Encoding.utf8)!
        let obj = BTJSON(data: JSON)

        XCTAssertEqual(obj.asEnum(["enum one" : "one"], orDefault: 1000), 1000)
    }

    func testIsNull() {
        let JSON = "null".data(using: String.Encoding.utf8)!
        let obj = BTJSON(data: JSON)

        XCTAssertTrue(obj.isNull);
    }

    func testIsObject() {
        let JSON = "{}".data(using: String.Encoding.utf8)!
        let obj = BTJSON(data: JSON)

        XCTAssertTrue(obj.isObject);
    }

    func testIsObjectForNonObject() {
        let JSON = "[]".data(using: String.Encoding.utf8)!
        let obj = BTJSON(data: JSON)

        XCTAssertFalse(obj.isObject);
    }

    func testLargerMixedJSONWithEmoji() {
        let jsonString =
        """
        {
          "aString": "Hello, JSON 😍!",
          "anArray": [
            { "key1": "val1" },
            { "key2": "val2" }
          ],
          "aLookupDictionary": {
            "foo": {
              "definition": "A meaningless word",
              "letterCount": 3,
              "meaningful": false
            }
          },
          "aURL": "https://test.example.com:1234/path",
          "anInvalidURL": ":™£¢://://://???!!!",
          "aTrue": true,
          "aFalse": false
        }
        """
        
        let obj = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        
        XCTAssertEqual(obj["aString"].asString(), "Hello, JSON 😍!")
        XCTAssertNil(obj["notAString"].asString()) // nil for absent keys
        XCTAssertNil(obj["anArray"].asString()) // nil for invalid values
        XCTAssertEqual(obj["anArray"].asArray()?.count, 2)
        XCTAssertEqual(obj["anArray"].asArray()?.first?["key1"].asString(), "val1")
        XCTAssertNil(obj["notAnArray"].asArray()) // nil for absent keys
        XCTAssertNil(obj["aString"].asArray()) // nil for invalid values

        let dictionary = obj["aLookupDictionary"].asDictionary()!
        let foo = dictionary["foo"]! as! Dictionary<String, AnyObject>
        XCTAssertEqual((foo["definition"] as! String), "A meaningless word")
        let letterCount = foo["letterCount"] as! NSNumber
        XCTAssertEqual(letterCount, 3)
        XCTAssertFalse(foo["meaningful"] as! Bool)
        XCTAssertNil((obj["notADictionary"] as AnyObject).asDictionary())
        XCTAssertNil((obj["aString"] as AnyObject).asDictionary())
        XCTAssertEqual((obj["aURL"] as AnyObject).asURL(), URL(string: "https://test.example.com:1234/path"))
        XCTAssertNil((obj["notAURL"] as AnyObject).asURL())
        XCTAssertNil((obj["aString"] as AnyObject).asURL())
        XCTAssertNil((obj["anInvalidURL"] as AnyObject).asURL()) // nil for invalid URLs
        // nested resources:
        let btJson = obj["aLookupDictionary"].asDictionary() as! [String: AnyObject]
        XCTAssertEqual((btJson["foo"] as! NSDictionary)["definition"] as! String, "A meaningless word")
        XCTAssertTrue(obj["aLookupDictionary"]["aString"]["anyting"].isError)
    }
}
