#import "BTJSON.h"

@implementation BTJSON

+ (instancetype)empty {
    // TODO
    return nil;
}

- (instancetype)init {
    // TODO
    return [self initWithValue:@{}];
}

- (instancetype)initWithData:(NSData *)data {
    // TODO
    return [self init];
}

- (instancetype)initWithValue:(id)value {
    // TODO
    return [super init];
}

#pragma mark Subscripting

- (BTJSON *)objectForKeyedSubscript:(NSString *)key {
    // TODO
    return nil;
}

- (BTJSON *)objectAtIndexedSubscript:(NSUInteger)idx {
    // TODO
    return nil;
}

// @name Validity Checks

- (BOOL)isError {
    // TODO
    return NO;
}

- (BT_NULLABLE NSError *)asError {
    // TODO
    return nil;
}

#pragma mark Generating JSON

- (nullable NSData *)asJSONAndReturnError:(NSError **)error {
    // TODO
    return nil;
}

- (nullable NSString *)asPrettyJSONAndReturnError:(NSError **)error {
    // TODO
    return nil;
}


#pragma mark JSON Type Casts

- (BT_NULLABLE NSString *)asString {
    // TODO
    return nil;
}

- (BT_NULLABLE BT_GENERICS(NSArray, BTJSON *) *)asArray {
    // TODO
    return nil;
}

- (BT_NULLABLE NSDecimalNumber *)asNumber {
    // TODO
    return nil;
}

#pragma mark JSON Extension Type Casts

- (BOOL)asTruthy {
    // TODO
    return NO;
}

- (BT_NULLABLE NSURL *)asURL {
    // TODO
    return nil;
}

- (BT_NULLABLE BT_GENERICS(NSArray, NSString *) *)asStringArray {
    // TODO
    return nil;
}

- (BT_NULLABLE BT_GENERICS(NSDictionary, NSString *, BTJSON *) *)asDictionary {
    // TODO
    return nil;
}

- (NSInteger)asIntegerOrZero {
    // TODO
    return 0;
}

- (BT_NULLABLE id)asAnyValue {
    // TODO
    return nil;
}

// @name JSON Type Checks

- (BOOL)isString {
    // TODO
    return NO;
}

- (BOOL)isNumber {
    // TODO
    return NO;
}

- (BOOL)isArray {
    // TODO
    return NO;
}

- (BOOL)isObject {
    // TODO
    return NO;
}

- (BOOL)isTrue {
    // TODO
    return NO;
}

- (BOOL)isFalse {
    // TODO
    return NO;
}

- (BOOL)isNull {
    // TODO
    return NO;
}

#pragma mark JSON Extension Type Checks

- (BOOL)isURL {
    // TODO
    return NO;
}

- (BOOL)isBOOL {
    // TODO
    return NO;
}


#pragma mark Setters

- (void)setObject:(id)value forKeyedSubscript:(NSString *)key {
    // TODO
}

- (void)setObject:(id)value atIndexedSubscript:(NSUInteger)idx {
    // TODO
}

- (void)setValue:(id)value {
    // TODO
}

@end
