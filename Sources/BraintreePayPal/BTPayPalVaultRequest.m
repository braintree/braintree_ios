#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalVaultRequest.h>
#else
#import <BraintreePayPal/BTPayPalVaultRequest.h>
#endif

// Swift Module Imports
#if __has_include(<Braintree/Braintree-Swift.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCore;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else                                            // Carthage
#import <BraintreeCore/BraintreeCore-Swift.h>
#endif

#import "BTPayPalRequest_Internal.h"

@implementation BTPayPalVaultRequest

- (NSString *)hermesPath {
    return @"v1/paypal_hermes/setup_billing_agreement";
}

- (BTPayPalPaymentType)paymentType {
    return BTPayPalPaymentTypeVault;
}

- (NSDictionary<NSString *, NSObject *> *)parametersWithConfiguration:(BTConfiguration *)configuration {
    NSMutableDictionary *parameters = [[super parametersWithConfiguration:configuration] mutableCopy];

    if (self.billingAgreementDescription.length > 0) {
        parameters[@"description"] = self.billingAgreementDescription;
    }

    parameters[@"offer_paypal_credit"] = @(self.offerCredit);

    if (self.shippingAddressOverride) {
        NSMutableDictionary *shippingAddressParams = [NSMutableDictionary dictionary];
        shippingAddressParams[@"line1"] = self.shippingAddressOverride.streetAddress;
        shippingAddressParams[@"line2"] = self.shippingAddressOverride.extendedAddress;
        shippingAddressParams[@"city"] = self.shippingAddressOverride.locality;
        shippingAddressParams[@"state"] = self.shippingAddressOverride.region;
        shippingAddressParams[@"postal_code"] = self.shippingAddressOverride.postalCode;
        shippingAddressParams[@"country_code"] = self.shippingAddressOverride.countryCodeAlpha2;
        shippingAddressParams[@"recipient_name"] = self.shippingAddressOverride.recipientName;
        parameters[@"shipping_address"] = shippingAddressParams;
    }

    return parameters;
}

@end
