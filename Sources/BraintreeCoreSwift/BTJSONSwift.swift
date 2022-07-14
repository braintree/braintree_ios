import Foundation


/// A type-safe wrapper around JSON
/// @see http://www.json.org/
///
/// The primary goal of this class is to two-fold: (1) prevent bugs by staying true to JSON (json.org)
/// rather than interpreting it in mysterious ways; (2) prevent bugs by making JSON interpretation
/// as un-surprising as possible.
///
/// Most notably, type casting occurs via the as* nullable methods; errors are deferred and can be checked explicitly using isError and asError.
///
/// ## Example Data:
/// ```
///    {
///      "foo": "bar",
///      "baz": [1, 2, 3]
///    }
/// ```
/// ## Example Usage:
/// ```
///    let json : BTJSON = BTJSON(data:data);
///    json.isError  // false
///    json.isObject // true
///    json.isNumber // false
///    json.asObject // self
///    json["foo"]   // JSON(@"bar")
///    json["foo"].isString // true
///    json["foo"].asString // @"bar"
///    json["baz"].asString // null
///    json["baz"]["quux"].isError // true
///    json["baz"]["quux"].asError // NSError(domain: BTJSONErrorDomain, code: BTJSONErrorCodeTypeInvalid)
///    json["baz"][0].asError // null
///    json["baz"][0].asInteger //
///    json["random"]["nested"]["things"][3].isError // true
///
///    let json : BTJSON = BTJSON() // json.asJson => {}
///    json["foo"][0] = "bar" // json.asJSON => { "foo": ["bar"] }
///    json["baz"] = [ 1, 2, 3 ] // json.asJSON => { "foo": ["bar"], "baz": [1,2,3] }
///    json["quux"] = NSSet() // json.isError => true, json.asJSON => throws NSError(domain: BTJSONErrorDomain, code: BTJSONErrorInvalidData)
/// ```
@objc public class BTJSONSwift: NSObject  {
    let value: Any
    
    init(value: Any) {
        self.value = value
    }
    
    subscript(index: Int) -> BTJSONSwift {
        get {
            guard let value = value as? [Any] else {
                return BTJSONSwift(value: BTJSONErrorSwift.indexInvalid(index))
            }
            return BTJSONSwift(value: value[index])
        }
    }
    
    subscript(key: String) -> BTJSONSwift {
        get {
            guard let value = value as? [String: Any],
                  let unwrappedResult = value[key] else {
                return BTJSONSwift(value: BTJSONErrorSwift.keyInvalid(key))
            }
            return BTJSONSwift(value: unwrappedResult)
        }
    }
    
    public func asString() -> String? {
        value as? String
    }
    
    public func asBool() -> Bool? {
        value as? Bool
    }
    
    public func asIntegerOrZero() -> Int? {
        value as? Int
    }
    
    public func asDictionary() -> [String: BTJSONSwift]? {
        value as? [String: BTJSONSwift]
    }
    
    public func asStringArray() -> [String]? {
        value as? [String]
    }
    
    public func asURL() -> URL? {
        guard let urlString = value as? String else {
            return nil
        }
        return URL(string: urlString)
    }
    
    public func asEnum(mapping: [String: Int], orDefault: Int) -> Int {
        guard let key = value as? String,
              let result = mapping[key] else {
            return orDefault
        }
        return result
    }
    
    func asNumber() -> NSNumber? {
        value as? NSNumber
    }
    
    func isString() -> Bool {
        value is String
    }
    
    func isBool() -> Bool {
        value is Bool
    }
    
    func isNumber() -> Bool {
        value is NSNumber
    }
    
    func isArray() -> Bool {
        value is Array<Any>
    }
    
    func isObject() -> Bool {
        value is [String: Any]
    }
    
    func isTrue() -> Bool {
        value as? Bool == true
    }
    
    func isFalse() -> Bool {
        value as? Bool == false
    }
    
    func isNull() -> Bool {
        value is NSNull
    }
}
