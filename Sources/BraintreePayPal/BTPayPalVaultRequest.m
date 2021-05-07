#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalVaultRequest.h>
#else
#import <BraintreePayPal/BTPayPalVaultRequest.h>
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
