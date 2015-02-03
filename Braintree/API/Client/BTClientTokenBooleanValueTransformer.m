#import "BTClientTokenBooleanValueTransformer.h"

@implementation BTClientTokenBooleanValueTransformer

+ (Class)transformedValueClass {
    return [NSNumber class];
}


+ (BOOL)allowsReverseTransformation {
    return NO;
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
