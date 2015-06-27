#import <Foundation/Foundation.h>
#import "BTNullability.h"

BT_ASSUME_NONNULL_BEGIN

/// A basic wrapper around JSON objects that make it run-time type safety more natural
///
/// The primary goal of this class is to two-fold: (1) prevent bugs by staying true to JSON (json.org)
/// rather than interpreting it in mysterious ways; (2) prevent bugs by making JSON interpretation
/// as un-surprising as possible.
///
/// Most notably, type casting occurs via the as* nullable methods; errors are deferred and can be checked explicitly using isError and asError.
///
/// ## Example data:
///    {
///      "foo": "bar",
///      "baz": [1, 2, 3]
///    }
///
/// ## Example Usage:
///
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
///     let json : BTJSON = BTJSON.empty // json.asJson => {}
///     json["foo"][0] = "bar" // json.asJSON => { "foo": ["bar"]
///     json["baz"] = [ 1, 2, 3 ] // json.asJSON => { "foo": ["bar"], "baz": [1,2,3] }
///     json["quux"] = NSSet() // json.isError => true, json.asJSON => throws NSError(domain: BTJSONErrorDomain, code: BTJSONErrorInvalidData)
@interface BTJSON : NSObject

+ (instancetype)empty;

- (instancetype)initWithData:(NSData *)data;

- (instancetype)initWithValue:(id)value;

// @name Subscripting

/// Indexes into the JSON as if the current value is an object
///
/// Notably, this method will always return successfully; however, if the value is not an object, the JSON will wrap an error.
- (BTJSON *)objectForKeyedSubscript:(NSString *)key;

/// Indexes into the JSON as if the current value is an array
///
/// Notably, this method will always return successfully; however, if the value is not an array, the JSON will wrap an error.
- (BTJSON *)objectAtIndexedSubscript:(NSUInteger)idx;

// @name Validity Checks

- (BOOL)isError;
- (BT_NULLABLE NSError *)asError;

// @name Generating JSON

- (nullable NSData *)asJSONAndReturnError:(NSError **)error;
- (nullable NSString *)asPrettyJSONAndReturnError:(NSError **)error;

// @name JSON Type Casts

- (BT_NULLABLE NSString *)asString;
- (BT_NULLABLE BT_GENERICS(NSArray, BTJSON *) *)asArray;
- (BT_NULLABLE NSDecimalNumber *)asNumber;

// @name JSON Extension Type Casts

- (BOOL)asTruthy;
- (BT_NULLABLE NSURL *)asURL;
- (BT_NULLABLE BT_GENERICS(NSArray, NSString *) *)asStringArray;
- (BT_NULLABLE BT_GENERICS(NSDictionary, NSString *, BTJSON *) *)asDictionary;
- (NSInteger)asIntegerOrZero;
- (BT_NULLABLE id)asAnyValue;

// @name JSON Type Checks

- (BOOL)isString;
- (BOOL)isNumber;
- (BOOL)isArray;
- (BOOL)isObject;
- (BOOL)isTrue;
- (BOOL)isFalse;
- (BOOL)isNull;

// @name JSON Extension Type Checks

- (BOOL)isURL;
- (BOOL)isBOOL;

// @name Setters

/// Sets the given value of the JSON object in a null safe manner
///
/// When `nil` is received, the given value is omitted or removed.
///
/// As it is the uncommon case, use `NSNull.null` to insert JSON `null`.
///
/// If the current value is not an object, isError will begin to return true, and asError will return the relevant error.
- (void)setObject:(id)value forKeyedSubscript:(NSString *)key;

- (void)setObject:(id)value atIndexedSubscript:(NSUInteger)idx;

- (void)setValue:(id)value;

@end

BT_ASSUME_NONNULL_END
