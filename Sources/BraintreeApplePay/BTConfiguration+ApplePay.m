#if __has_include(<Braintree/BraintreeApplePay.h>)
#import <Braintree/BTConfiguration+ApplePay.h>
#else
#import <BraintreeApplePay/BTConfiguration+ApplePay.h>
#endif

// Swift Module Imports
#if __has_include(<Braintree/Braintree-Swift.h>) // Cocoapods-generated Swift Header
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCoreSwift;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else // Carthage or Local Builds
#import <BraintreeCoreSwift/BraintreeCoreSwift-Swift.h>
#endif

@implementation BTConfiguration (ApplePay)

- (BOOL)isApplePayEnabled {
    BTJSON *applePayConfiguration = self.json[@"applePay"];
    return [applePayConfiguration[@"status"] isString] && ![[applePayConfiguration[@"status"] asString] isEqualToString:@"off"];
}

- (BOOL)canMakeApplePayPayments {
    return [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:self.applePaySupportedNetworks];
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
    
    for (NSString *gatewaySupportedNetwork in gatewaySupportedNetworks) {
        if ([gatewaySupportedNetwork localizedCaseInsensitiveCompare:@"visa"] == NSOrderedSame) {
            [supportedNetworks addObject:PKPaymentNetworkVisa];
        } else if ([gatewaySupportedNetwork localizedCaseInsensitiveCompare:@"mastercard"] == NSOrderedSame) {
            [supportedNetworks addObject:PKPaymentNetworkMasterCard];
        } else if ([gatewaySupportedNetwork localizedCaseInsensitiveCompare:@"amex"] == NSOrderedSame) {
            [supportedNetworks addObject:PKPaymentNetworkAmex];
        } else if ([gatewaySupportedNetwork localizedCaseInsensitiveCompare:@"discover"] == NSOrderedSame) {
            [supportedNetworks addObject:PKPaymentNetworkDiscover];
        } else if ([gatewaySupportedNetwork localizedCaseInsensitiveCompare:@"maestro"] == NSOrderedSame) {
            [supportedNetworks addObject:PKPaymentNetworkMaestro];
        } else if ([gatewaySupportedNetwork localizedCaseInsensitiveCompare:@"elo"] == NSOrderedSame) {
            [supportedNetworks addObject:PKPaymentNetworkElo];
        }
    }
    return [supportedNetworks copy];
}

@end
