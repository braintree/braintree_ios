#if BT_ENABLE_APPLE_PAY
#import "BTClientTokenApplePayPaymentNetworksValueTransformer.h"

@implementation BTClientTokenApplePayPaymentNetworksValueTransformer

+ (instancetype)sharedInstance {
    static BTClientTokenApplePayPaymentNetworksValueTransformer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)transformedValue:(id)value {
    if ([PKPaymentRequest class]) {
        if ([value isEqualToString:@"amex"]) {
            return PKPaymentNetworkAmex;
        } else if ([value isEqualToString:@"visa"]) {
            return PKPaymentNetworkVisa;
        } else if ([value isEqualToString:@"mastercard"]) {
            return PKPaymentNetworkMasterCard;
        } else if (&PKPaymentNetworkDiscover != NULL && [value isEqualToString:@"discover"]) {
            return PKPaymentNetworkDiscover;
        }
    }

    return [NSNull null];
}

@end
#endif

