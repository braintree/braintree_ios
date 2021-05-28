#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Domain for JSON errors.
 */
extern NSString * const BTJSONErrorDomain;

/**
 Error codes associated with `BTJSON`.
 */
typedef NS_ENUM(NSInteger, BTJSONErrorCode) {
    /// Unknown value
    BTJSONErrorValueUnknown = 0,

    /// Invalid value
    BTJSONErrorValueInvalid = 1,

    /// Invalid access
    BTJSONErrorAccessInvalid = 2,
};

/**
 A type-safe wrapper around JSON

 @see http://www.json.org/

 The primary goal of this class is to two-fold: (1) prevent bugs by staying true to JSON (json.org)
 rather than interpreting it in mysterious ways; (2) prevent bugs by making JSON interpretation
 as un-surprising as possible.

 Most notably, type casting occurs via the as* nullable methods; errors are deferred and can be checked explicitly using isError and asError.
 
 ## Example Data:
 ```
    {
      "foo": "bar",
      "baz": [1, 2, 3]
    }
 ```
 ## Example Usage:
 ```
    let json : BTJSON = BTJSON(data:data);
    json.isError  // false
    json.isObject // true
    json.isNumber // false
    json.asObject // self
    json["foo"]   // JSON(@"bar")
    json["foo"].isString // true
    json["foo"].asString // @"bar"
    json["baz"].asString // null
    json["baz"]["quux"].isError // true
    json["baz"]["quux"].asError // NSError(domain: BTJSONErrorDomain, code: BTJSONErrorCodeTypeInvalid)
    json["baz"][0].asError // null
    json["baz"][0].asInteger //
    json["random"]["nested"]["things"][3].isError // true

    let json : BTJSON = BTJSON() // json.asJson => {}
    json["foo"][0] = "bar" // json.asJSON => { "foo": ["bar"] }
    json["baz"] = [ 1, 2, 3 ] // json.asJSON => { "foo": ["bar"], "baz": [1,2,3] }
    json["quux"] = NSSet() // json.isError => true, json.asJSON => throws NSError(domain: BTJSONErrorDomain, code: BTJSONErrorInvalidData)
 ```
*/
@interface BTJSON : NSObject

/**
 Designated initializer.
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 Initialize with a value.
 
 @param value The value to initialize with.
 */
- (instancetype)initWithValue:(id)value;

/**
 Initialize with a data.
 
 @param data The `NSData` to initialize with.
 */
- (instancetype)initWithData:(NSData *)data;

/// Subscripting

/**
 Indexes into the JSON as if the current value is an object

 Notably, this method will always return successfully; however, if the value is not an object, the JSON will wrap an error.
*/
- (BTJSON *)objectForKeyedSubscript:(NSString *)key;

/**
 Indexes into the JSON as if the current value is an array

 Notably, this method will always return successfully; however, if the value is not an array, the JSON will wrap an error.
*/
- (BTJSON *)objectAtIndexedSubscript:(NSUInteger)idx;

/// Validity Checks

/**
 True if this instance of BTJSON is not valid.
 */
@property (nonatomic, assign, readonly) BOOL isError;

/**
 The BTJSON as `NSError`.
 
 @return An `NSError` representing the BTJSON instance.
 */
- (nullable NSError *)asError;

/// Generating JSON

/**
 The BTJSON as `NSData`.
 
 @param error Used if there is an issue parsing.
 @return An `NSData` representing the BTJSON instance.
 */
- (nullable NSData *)asJSONAndReturnError:(NSError **)error;

/**
 The BTJSON as a pretty string.
 
 @param error Used if there is an issue parsing.
 @return An `NSString` representing the BTJSON instance.
 */
- (nullable NSString *)asPrettyJSONAndReturnError:(NSError **)error;

/// JSON Type Casts

/**
 The BTJSON as `NSString`.
 
 @return An `NSString` representing the BTJSON instance.
 */
- (nullable NSString *)asString;

/**
 The BTJSON as `NSArray<BTJSON *>`.
 
 @return An `NSArray<BTJSON *>` representing the BTJSON instance.
 */
- (nullable NSArray<BTJSON *> *)asArray;

/**
 The BTJSON as `NSDecimalNumber`.
 
 @return An `NSDecimalNumber` representing the BTJSON instance.
 */
- (nullable NSDecimalNumber *)asNumber;

/// JSON Extension Type Casts

/**
 The BTJSON as `NSURL`.
 
 @return An `NSURL` representing the BTJSON instance.
 */
- (nullable NSURL *)asURL;

/**
 The BTJSON as `NSArray<NSString *>`.
 
 @return An `NSArray<NSString *>` representing the BTJSON instance.
 */
- (nullable NSArray<NSString *> *)asStringArray;

/**
 The BTJSON as `NSDictionary`.
 
 @return An `NSDictionary` representing the BTJSON instance.
 */
- (nullable NSDictionary *)asDictionary;

/**
 The BTJSON as `NSInteger`. Zero will be returned if not a valid number.
 
 @return An `NSInteger` representing the BTJSON instance.
 */
- (NSInteger)asIntegerOrZero;

/**
 The BTJSON as Enum.
 
 @param mapping The mapping dictionary to used to convert the value.
 @param defaultValue The default value if conversion fails.
 @return An Enum representing the BTJSON instance.
 */
- (NSInteger)asEnum:(NSDictionary *)mapping orDefault:(NSInteger)defaultValue;

/// JSON Type Checks

/**
 True if this instance of BTJSON is a valid string.
 */
@property (nonatomic, assign, readonly) BOOL isString;

/**
 True if this instance of BTJSON is a valid number.
 */
@property (nonatomic, assign, readonly) BOOL isNumber;

/**
 True if this instance of BTJSON is a valid array.
 */
@property (nonatomic, assign, readonly) BOOL isArray;

/**
 True if this instance of BTJSON is a valid object.
 */
@property (nonatomic, assign, readonly) BOOL isObject;

/**
 True if this instance of BTJSON is a boolean.
 */
@property (nonatomic, assign, readonly) BOOL isBool;

/**
 True if this instance of BTJSON is a value representing `true`.
 */
@property (nonatomic, assign, readonly) BOOL isTrue;

/**
 True if this instance of BTJSON is a value representing `false`.
 */
@property (nonatomic, assign, readonly) BOOL isFalse;

/**
 True if this instance of BTJSON is `null`.
 */
@property (nonatomic, assign, readonly) BOOL isNull;

@end

NS_ASSUME_NONNULL_END
