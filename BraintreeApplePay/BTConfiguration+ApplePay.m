#import "BTConfiguration+ApplePay.h"
#import <PassKit/PassKit.h>

@implementation BTConfiguration (ApplePay)

- (BOOL)isApplePayEnabled {
    BTJSON *applePayConfiguration = self.json[@"applePay"];
    return [applePayConfiguration[@"status"] isString] && ![[applePayConfiguration[@"status"] asString] isEqualToString:@"off"];
}

- (NSArray <NSString *> *) supportedCardNetworks {
    NSMutableArray *supportedCardNetworks = [NSMutableArray array];
    BTJSON *applePayConfiguration = self.json[@"applePay"];
    if (applePayConfiguration) {
        for (NSString *btSupportedNetwork in [applePayConfiguration[@"supportedNetworks"] asArray]) {
            if ([btSupportedNetwork isEqualToString:@"visa"]) {
                [supportedCardNetworks addObject:PKPaymentNetworkVisa];
            } else if ([btSupportedNetwork isEqualToString:@"mastercard"]) {
                [supportedCardNetworks addObject:PKPaymentNetworkMasterCard];
            } else if ([btSupportedNetwork isEqualToString:@"discover"]) {
                [supportedCardNetworks addObject:PKPaymentNetworkDiscover];
            } else if ([btSupportedNetwork isEqualToString:@"amex"]) {
                [supportedCardNetworks addObject:PKPaymentNetworkAmex];
            } else if ([btSupportedNetwork isEqualToString:@"unionpay"]) {
                [supportedCardNetworks addObject:PKPaymentNetworkChinaUnionPay];
            }
        }
    }
    return supportedCardNetworks;
}

@end
