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
@objcMembers public class BTJSON: NSObject {
    var value: Any? = [:]

    // MARK: Initializers

    public override init() { }

    ///  Initialize with a value.
    /// - Parameter value: The value to initialize with.
    public convenience init(value: Any?) {
        self.init()
        self.value = value
    }

    /// Initialize with data.
    /// - Parameter data: The `Data` to initialize with.
    public convenience init(data: Data) {
        do {
            let value = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            self.init(value: value)
        } catch {
            self.init(value: error)
        }
    }

    // MARK: JSON Type Checks

    /// Checks if the `BTJSON` is a `String`
    /// - Returns: `true` if this instance of `BTJSON` is a valid `String`
    public var isString: Bool {
        value is String
    }

    /// Checks if the `BTJSON` is a `Bool`
    /// - Returns: `true` if this instance of `BTJSON` is a valid `Bool`
    public var isBool: Bool {
        value is Bool
    }

    /// Checks if the `BTJSON` is a `NSNumber`
    /// - Returns: `true` if this instance of `BTJSON` is a valid `NSNumber`
    public var isNumber: Bool {
        value is NSNumber
    }

    /// Checks if the `BTJSON` is a `[Any]`
    /// - Returns: `true` if this instance of `BTJSON` is a valid `[Any]`
    public var isArray: Bool {
        value is [Any]
    }

    /// Checks if the `BTJSON` is a `[String: Any]`
    /// - Returns: `true` if this instance of `BTJSON` is a valid `[String: Any]`
    public var isObject: Bool {
        value is [String: Any]
    }

    /// Checks if the `BTJSON` is an error.
    /// - Returns: `true` if this instance of `BTJSON` is not valid.
    public var isError: Bool {
        value is NSError
    }

    /// Checks if the `BTJSON` is a value representing `true`
    /// - Returns: `true` if this instance of `BTJSON` is `true`
    public var isTrue: Bool {
        value as? Bool == true
    }

    /// Checks if the `BTJSON` is a value representing `false`
    /// - Returns: `true` if this instance of `BTJSON` is `false`
    public var isFalse: Bool {
        value as? Bool == false
    }

    /// Checks if the `BTJSON` is a value representing `nil`
    /// - Returns: `true` if this instance of `BTJSON` is `nil`
    public var isNull: Bool {
        value is NSNull
    }

    // MARK: Subscripting

    ///  Indexes into the JSON as if the current value is an object
    ///
    /// Notably, this method will always return successfully; however, if the value is not an object, the JSON will wrap an error.
    public subscript(index: Int) -> BTJSON {
        if value is NSError {
            return self
        }

        guard let value = value as? [Any], index < value.count else {
            return BTJSON(value: BTJSONError.indexInvalid(index))
        }
        return BTJSON(value: value[index])
    }

    /// Indexes into the JSON as if the current value is an array
    ///
    /// Notably, this method will always return successfully; however, if the value is not an array, the JSON will wrap an error.
    public subscript(key: String) -> BTJSON {
        if value is NSError {
            return self
        }

        guard let value = value as? [String: Any],
              let unwrappedResult = value[key] else {
            return BTJSON(value: BTJSONError.keyInvalid(key))
        }
        return BTJSON(value: unwrappedResult)
    }

    // MARK: Validity Checks

    /// The `BTJSON` as a `NSError`.
    /// - Returns: A `NSError` representing the `BTJSON` instance.
    public func asError() -> NSError? {
        value as? NSError
    }

    // MARK: JSON Type Casts

    /// The `BTJSON` as a `String`
    /// - Returns: A `String` representing the `BTJSON` instance
    public func asString() -> String? {
        value as? String
    }

    /// The `BTJSON` as a `Bool`
    /// - Returns: A `Bool` representing the `BTJSON` instance
    public func asBool() -> Bool? {
        value as? Bool
    }

    /// The `BTJSON` as a `[BTJSON]`
    /// - Returns: A `[BTJSON]` representing the `BTJSON` instance
    public func asArray() -> [BTJSON]? {
        var array: NSMutableArray? = []

        if value is [Any], let arrayValue = value as? [Any] {
            for element in arrayValue {
                array?.add(BTJSON(value: element))
            }
        } else {
            array = nil
        }

        return array as? [BTJSON]
    }

    /// The `BTJSON` as a `NSNumber`
    /// - Returns: A `NSNumber` representing the `BTJSON` instance
    public func asNumber() -> NSNumber? {
        value as? NSNumber
    }

    // MARK: JSON Extension Type Casts

    /// The `BTJSON` as a `URL`
    /// - Returns: A `URL` representing the `BTJSON` instance
    public func asURL() -> URL? {
        guard let urlString = value as? String else {
            return nil
        }
        return URL(string: urlString)
    }

    /// The `BTJSON` as a `[String]`
    /// - Returns: A `[String]` representing the `BTJSON` instance
    public func asStringArray() -> [String]? {
        value as? [String]
    }

    /// The `BTJSON` as a `NSDictionary`
    /// - Returns: A `NSDictionary` representing the `BTJSON` instance
    public func asDictionary() -> NSDictionary? {
        value as? NSDictionary
    }

    /// The `BTJSON` as a `Int`
    /// - Returns: A `Int` representing the `BTJSON` instance
    public func asIntegerOrZero() -> Int {
        let number = value as? NSNumber ?? 0
        return number.intValue
    }

    /// The `BTJSON` as an `Enum`
    /// - Parameters:
    ///   - mapping: The mapping dictionary used to convert the value
    ///   - orDefault: The default value if conversion fails
    /// - Returns: An `Enum` representing the `BTJSON` instance
    public func asEnum(_ mapping: [String: Any], orDefault: Int) -> Int {
        guard let key = value as? String,
              let result: Int = mapping[key] as? Int else {
            return orDefault
        }

        return result
    }
    
    /// The `BTJSON` as a `BTPostalAddress`
    /// - Returns: A `BTPostalAddress` parsed from the key/value pairs inside the `BTJSON`
    public func asAddress() -> BTPostalAddress? {
        guard self.isObject else { return nil }
        
        let address = BTPostalAddress()
        address.recipientName = self["recipientName"].asString() // Likely to be nil
        address.streetAddress = self["street1"].asString() ?? self["line1"].asString()
        address.extendedAddress = self["street2"].asString() ?? self["line2"].asString()
        address.locality = self["city"].asString()
        address.region = self["state"].asString()
        address.postalCode = self["postalCode"].asString()
        address.countryCodeAlpha2 = self["country"].asString() ?? self["countryCode"].asString()
        return address
    }
}
