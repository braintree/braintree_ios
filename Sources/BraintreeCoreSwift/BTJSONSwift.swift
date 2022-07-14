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
    

}
