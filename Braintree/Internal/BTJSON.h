#import <Foundation/Foundation.h>
#import "BTNullability.h"

BT_ASSUME_NONNULL_BEGIN

extern NSString * const BTJSONErrorDomain;

typedef NS_ENUM(NSInteger, BTJSONErrorCode) {
    BTJSONErrorValueUnknown = 0,
    BTJSONErrorValueInvalid = 1,
    BTJSONErrorAccessInvalid = 2,
};

/// A basic wrapper around JSON objects that make it run-time type safety more natural
///
/// http://www.json.org/
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
///     let json : BTJSON = BTJSON() // json.asJson => {}
///     json["foo"][0] = "bar" // json.asJSON => { "foo": ["bar"] }
///     json["baz"] = [ 1, 2, 3 ] // json.asJSON => { "foo": ["bar"], "baz": [1,2,3] }
///     json["quux"] = NSSet() // json.isError => true, json.asJSON => throws NSError(domain: BTJSONErrorDomain, code: BTJSONErrorInvalidData)
@interface BTJSON : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithValue:(id)value;

- (instancetype)initWithData:(NSData *)data;

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

@property (nonatomic, assign, readonly) BOOL isError;

- (BT_NULLABLE NSError *)asError;

// @name Generating JSON

- (nullable NSData *)asJSONAndReturnError:(NSError **)error;
- (nullable NSString *)asPrettyJSONAndReturnError:(NSError **)error;

// @name JSON Type Casts

- (BT_NULLABLE NSString *)asString;

- (BT_NULLABLE BT_GENERICS(NSArray, BTJSON *) *)asArray;

- (BT_NULLABLE NSDecimalNumber *)asNumber;

// @name JSON Extension Type Casts

- (BT_NULLABLE NSURL *)asURL;

- (BT_NULLABLE BT_GENERICS(NSArray, NSString *) *)asStringArray;

- (BT_NULLABLE NSDictionary *)asDictionary;

- (NSInteger)asIntegerOrZero;

- (NSInteger)asEnum:(NSDictionary *)mapping orDefault:(NSInteger)defaultValue;

// @name JSON Type Checks

@property (nonatomic, assign, readonly) BOOL isString;

@property (nonatomic, assign, readonly) BOOL isNumber;

@property (nonatomic, assign, readonly) BOOL isArray;

@property (nonatomic, assign, readonly) BOOL isObject;

@property (nonatomic, assign, readonly) BOOL isTrue;

@property (nonatomic, assign, readonly) BOOL isFalse;

@property (nonatomic, assign, readonly) BOOL isNull;

//// @name Setters
//
///// Sets the given value of the JSON object in a null safe manner
/////
///// When `nil` is received, the given value is omitted or removed.
/////
///// As it is the uncommon case, use `NSNull.null` to insert JSON `null`.
/////
///// If the current value is not an object, isError will begin to return true, and asError will return the relevant error.
//- (void)setObject:(id)value forKeyedSubscript:(NSString *)key;
//
//- (void)setObject:(id)value atIndexedSubscript:(NSUInteger)idx;
//
//- (void)setValue:(id)value;

@end

BT_ASSUME_NONNULL_END
