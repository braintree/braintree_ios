#import "BTJSON.h"

NSString * const BTJSONErrorDomain = @"com.briantreepayments.BTJSONErrorDomain";

@interface BTJSON ()

@property (nonatomic, strong) NSArray *subscripts;
@property (nonatomic, strong) id value;

@end

@implementation BTJSON

@synthesize value = _value;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.subscripts = [NSMutableArray array];
        self.value = @{};
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    if (data == nil) {
        return self = [self initWithValue:@{}];
    }

    NSError *error;
    id value = [NSJSONSerialization JSONObjectWithData:data
                                               options:NSJSONReadingAllowFragments
                                                 error:&error];
    if (error != nil) {
        return self = [self initWithValue:error];
    }

    return self = [self initWithValue:value];
}

- (instancetype)initWithValue:(id)value {
    self = [self init];
    if (self) {
        self.value = value;
    }
    return self;
}


#pragma mark Subscripting

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self JSONForKey:key];
}

- (BTJSON *)JSONForKey:(NSString *)key {
    BTJSON *json = [[BTJSON alloc] initWithValue:_value];
    json.subscripts = [self.subscripts arrayByAddingObject:key];

    return json;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self JSONAtIndex:idx];
}

- (BTJSON *)JSONAtIndex:(NSUInteger)idx {
    BTJSON *json = [[BTJSON alloc] initWithValue:_value];
    json.subscripts = [self.subscripts arrayByAddingObject:@(idx)];

    return json;
}

- (id)value {
    id value = _value;
    for (id key in self.subscripts) {
        if ([value isKindOfClass:[NSArray class]]) {
            if (![key isKindOfClass:[NSNumber class]]) {
                value = [self chainedErrorOrErrorWithCode:BTJSONErrorAccessInvalid userInfo:nil];
                break;
            }

            NSInteger idx = [(NSNumber *)key integerValue];
            if (idx >= [(NSArray *)value count]) {
                value = nil;
                break;
            }

            value = [value objectAtIndexedSubscript:idx];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            if (![key isKindOfClass:[NSString class]]) {
                value = [self chainedErrorOrErrorWithCode:BTJSONErrorAccessInvalid userInfo:nil];
                break;
            }

            value = [value objectForKeyedSubscript:key];
        } else {
            value = [self chainedErrorOrErrorWithCode:BTJSONErrorValueInvalid userInfo:@{ NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Attempted to index into a value that is neither an object nor an array using key (%@).", key] }];
            break;
        }
    }
    return value;
}

#pragma mark Setters

//- (void)setValue:(id)newValue {
//    _value = newValue;
//}
//
//- (void)setObject:(id)value forKeyedSubscript:(NSString *)key {
//    if ([self.value isKindOfClass:[NSDictionary class]]) {
//        NSMutableDictionary *mutableValueCopy = [_value mutableCopy];
//        mutableValueCopy[key] = value;
//        self.value = [mutableValueCopy copy];
//    }
//}
//
//- (void)setObject:(id)value atIndexedSubscript:(NSUInteger)idx {
//    if ([self.value isKindOfClass:[NSArray class]]) {
//        NSMutableArray *mutableValueCopy = [self.value mutableCopy];
//        mutableValueCopy[idx] = value;
//        self.value = [mutableValueCopy copy];
//    }
//}


#pragma mark Validity Checks

- (BOOL)isError {
    return [self.value isKindOfClass:[NSError class]];
}

- (BT_NULLABLE NSError *)asError {
    if (![self.value isKindOfClass:[NSError class]]) {
        return nil;
    }

    return self.value;
}

#pragma mark Generating JSON

- (nullable NSData *)asJSONAndReturnError:(NSError **)error {
    return [NSJSONSerialization dataWithJSONObject:self.value
                                           options:0
                                             error:error];
}

- (nullable NSString *)asPrettyJSONAndReturnError:(NSError **)error {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.value
                                                                          options:NSJSONWritingPrettyPrinted
                                                                            error:error]
                                 encoding:NSUTF8StringEncoding];
}


#pragma mark JSON Type Casts

- (BT_NULLABLE NSString *)asString {
    if (![self.value isKindOfClass:[NSString class]]) {
        return nil;
    }

    return self.value;
}

- (BT_NULLABLE BT_GENERICS(NSArray, BTJSON *) *)asArray {
    if (![self.value isKindOfClass:[NSArray class]]) {
        return nil;
    }

    return self.value;
}

- (BT_NULLABLE NSDecimalNumber *)asNumber {
    if (![self.value isKindOfClass:[NSNumber class]]) {
        return nil;
    }

    return [NSDecimalNumber decimalNumberWithDecimal:[self.value decimalValue]];
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
    return self.value;
}

// @name JSON Type Checks

- (BOOL)isString {
    return [self.value isKindOfClass:[NSString class]];
}

- (BOOL)isNumber {
    return [self.value isKindOfClass:[NSNumber class]];
}

- (BOOL)isArray {
    return [self.value isKindOfClass:[NSArray class]];
}

- (BOOL)isObject {
    return [self.value isKindOfClass:[NSObject class]];
}

- (BOOL)isTrue {
    return [self.value isEqual:@YES];
}

- (BOOL)isFalse {
    return [self.value isEqual:@NO];
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
    return [self.value isEqual:@YES] || [self.value isEqual:@NO];
}

#pragma mark Error Handling

- (NSError *)chainedErrorOrErrorWithCode:(NSInteger)code
                               userInfo:(NSDictionary *)userInfo {
    if ([_value isKindOfClass:[NSError class]]) {
        return _value;
    }

    return [NSError errorWithDomain:BTJSONErrorDomain
                               code:code
                           userInfo:userInfo];
}

#pragma mark -

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<BTJSON:%p value:%@>", self, self.value];
}

@end
