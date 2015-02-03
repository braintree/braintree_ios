#import "BTClientTokenApplePayStatusValueTransformer.h"
#import "BTClientToken.h"

@implementation BTClientTokenApplePayStatusValueTransformer

+ (Class)transformedValueClass {
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value isEqualToString:@"off"]) {
        return @(BTClientApplePayStatusOff);
    } else if ([value isEqualToString:@"mock"]) {
        return @(BTClientApplePayStatusMock);
    } else if ([value isEqualToString:@"production"]) {
        return @(BTClientApplePayStatusProduction);
    }
    return [NSNull null];
}

@end
