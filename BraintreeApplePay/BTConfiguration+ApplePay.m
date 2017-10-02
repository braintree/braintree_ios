#import "BTConfiguration+ApplePay.h"
#import <PassKit/PassKit.h>

@implementation BTConfiguration (ApplePay)

- (BOOL)isApplePayEnabled {
    BTJSON *applePayConfiguration = self.json[@"applePay"];
    return [applePayConfiguration[@"status"] isString] && ![[applePayConfiguration[@"status"] asString] isEqualToString:@"off"];
}

- (BOOL)canMakeApplePayPayments {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 8.0, watchOS 3.0, *)) {
#endif
    return [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:self.applePaySupportedNetworks];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    } else {
        return NO;
    }
#endif
}

- (NSString *)applePayCountryCode {
    return [self.json[@"applePay"][@"countryCode"] asString];
}

- (NSString *)applePayCurrencyCode {
    return [self.json[@"applePay"][@"currencyCode"] asString];
}

- (NSString *)applePayMerchantIdentifier {
    return [self.json[@"applePay"][@"merchantIdentifier"] asString];
}

- (NSArray<PKPaymentNetwork> *)applePaySupportedNetworks {
    NSArray <NSString *> *gatewaySupportedNetworks = [self.json[@"applePay"][@"supportedNetworks"] asStringArray];

    NSMutableArray <PKPaymentNetwork> *supportedNetworks = [NSMutableArray new];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 8.0, watchOS 3.0, *)) {
#endif
    for (NSString *gatewaySupportedNetwork in gatewaySupportedNetworks) {
        if ([gatewaySupportedNetwork localizedCaseInsensitiveCompare:@"visa"] == NSOrderedSame) {
            [supportedNetworks addObject:PKPaymentNetworkVisa];
        } else if ([gatewaySupportedNetwork localizedCaseInsensitiveCompare:@"mastercard"] == NSOrderedSame) {
            [supportedNetworks addObject:PKPaymentNetworkMasterCard];
        } else if ([gatewaySupportedNetwork localizedCaseInsensitiveCompare:@"amex"] == NSOrderedSame) {
            [supportedNetworks addObject:PKPaymentNetworkAmex];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        } else if ([gatewaySupportedNetwork localizedCaseInsensitiveCompare:@"discover"] == NSOrderedSame) {
            if (@available(iOS 9.0, watchOS 3.0, *)) {
                [supportedNetworks addObject:PKPaymentNetworkDiscover];
            }
        }
#else
        } else if (&PKPaymentNetworkDiscover != NULL && [gatewaySupportedNetwork localizedCaseInsensitiveCompare:@"discover"] == NSOrderedSame) { // Very important to check that this constant is available first!
            [supportedNetworks addObject:PKPaymentNetworkDiscover];
        }
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    }
#endif
    }

    return [supportedNetworks copy];
}

@end
