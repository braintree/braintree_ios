#import "BTPayPalCheckoutRequest_Internal.h"
#import "BTPayPalRequest_Internal.h"

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

@implementation BTPayPalCheckoutRequest

- (instancetype)initWithAmount:(NSString *)amount {
    if (amount == nil) {
        return nil;
    }

    if (self = [super init]) {
        _amount = amount;
        _offerPayLater = NO;
        _intent = BTPayPalRequestIntentAuthorize;
        _userAction = BTPayPalRequestUserActionDefault;
    }
    return self;
}

- (NSString *)intentAsString {
    switch(self.intent) {
        case BTPayPalRequestIntentSale:
            return @"sale";
        case BTPayPalRequestIntentOrder:
            return @"order";
        default:
            return @"authorize";
    }
}

- (NSString *)userActionAsString {
    switch(self.userAction) {
        case BTPayPalRequestUserActionCommit:
            return @"commit";
        default:
            return @"";
    }
}

- (NSString *)hermesPath {
    return @"v1/paypal_hermes/create_payment_resource";
}

- (BTPayPalPaymentType)paymentType {
    return BTPayPalPaymentTypeCheckout;
}

- (NSDictionary<NSString *, NSObject *> *)parametersWithConfiguration:(BTConfiguration *)configuration {
    NSMutableDictionary *parameters = [[super parametersWithConfiguration:configuration] mutableCopy];
    parameters[@"intent"] = self.intentAsString;
    parameters[@"amount"] = self.amount;
    parameters[@"offer_pay_later"] = @(self.offerPayLater);

    NSString *currencyCode = self.currencyCode ?: [configuration.json[@"paypal"][@"currencyIsoCode"] asString];
    if (currencyCode) {
        parameters[@"currency_iso_code"] = currencyCode;
    }

    if (self.requestBillingAgreement) {
        parameters[@"request_billing_agreement"] = @(self.requestBillingAgreement);
    }

    if (self.requestBillingAgreement && self.billingAgreementDescription) {
        parameters[@"billing_agreement_details"] = @{@"description": self.billingAgreementDescription};
    }

    if (self.shippingAddressOverride) {
        parameters[@"line1"] = self.shippingAddressOverride.streetAddress;
        parameters[@"line2"] = self.shippingAddressOverride.extendedAddress;
        parameters[@"city"] = self.shippingAddressOverride.locality;
        parameters[@"state"] = self.shippingAddressOverride.region;
        parameters[@"postal_code"] = self.shippingAddressOverride.postalCode;
        parameters[@"country_code"] = self.shippingAddressOverride.countryCodeAlpha2;
        parameters[@"recipient_name"] = self.shippingAddressOverride.recipientName;
    }

    return parameters;
}

@end
