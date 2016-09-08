#import "BTConfiguration+ApplePay.h"
#import <PassKit/PassKit.h>

@implementation BTConfiguration (ApplePay)

- (BOOL)isApplePayEnabled {
    BTJSON *applePayConfiguration = self.json[@"applePay"];
    return [applePayConfiguration[@"status"] isString] && ![[applePayConfiguration[@"status"] asString] isEqualToString:@"off"];
}

- (NSArray *)applePaySupportedNetworks {
    BTJSON *applePayConfiguration = self.json[@"applePay"];
    if (applePayConfiguration == nil) {
        return [NSArray array];
    }
    
    NSArray *supportedNetworks = [applePayConfiguration[@"supportedNetworks"] asArray];
    NSMutableArray *applePaySupportedNetworks = [[NSMutableArray alloc] init];
    for (NSString *network in supportedNetworks) {
        if ([network isEqualToString:@"visa"]) {
            [applePaySupportedNetworks addObject:PKPaymentNetworkVisa];
        } else if ([network isEqualToString:@"mastercard"]) {
            [applePaySupportedNetworks addObject:PKPaymentNetworkMasterCard];
        } else if ([network isEqualToString:@"discover"]) {
            [applePaySupportedNetworks addObject:PKPaymentNetworkDiscover];
        } else if ([network isEqualToString:@"amex"]) {
            [applePaySupportedNetworks addObject:PKPaymentNetworkAmex];
        }
    }
    return applePaySupportedNetworks;
}

- (BOOL)canMakeApplePayPayments {
    return [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:[self applePaySupportedNetworks]];
}

@end
