#import "BTClientTokenBooleanValueTransformer.h"

@implementation BTClientTokenBooleanValueTransformer

+ (instancetype)sharedInstance {
    static BTClientTokenBooleanValueTransformer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSString class]] && [value length] > 0) {
        return @YES;
    } else {
        return @NO;
    }
}

@end
