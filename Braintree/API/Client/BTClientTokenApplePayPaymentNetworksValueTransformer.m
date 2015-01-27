#import "BTClientTokenApplePayPaymentNetworksValueTransformer.h"

@implementation BTClientTokenApplePayPaymentNetworksValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([PKPaymentRequest class]) {
        if ([value isEqualToString:@"amex"]) {
            return PKPaymentNetworkAmex;
        } else if ([value isEqualToString:@"visa"]) {
            return PKPaymentNetworkVisa;
        } else if ([value isEqualToString:@"mastercard"]) {
            return PKPaymentNetworkMasterCard;
        }
    }

    return [NSNull null];
}

@end

