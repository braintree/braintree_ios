#if BT_ENABLE_APPLE_PAY
#import "BTClientTokenApplePayStatusValueTransformer.h"
#import "BTClientToken.h"
#import "BTConfiguration.h" // For BTClientApplePayStatus* enums

@implementation BTClientTokenApplePayStatusValueTransformer

+ (instancetype)sharedInstance {
    static BTClientTokenApplePayStatusValueTransformer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
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
#endif
