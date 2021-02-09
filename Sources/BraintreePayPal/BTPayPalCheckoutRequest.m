#import "BTPayPalCheckoutRequest_Internal.h"
#import "BTPayPalRequest_Internal.h"

@implementation BTPayPalCheckoutRequest

- (instancetype)initWithAmount:(NSString *)amount {
    if (amount == nil) {
        return nil;
    }

    if (self = [super init]) {
        _amount = amount;
        _offerPayLater = NO;
        _intent = BTPayPalRequestIntentAuthorize;
    }
    return self;
}

- (NSDictionary<NSString *, NSObject *> *)parametersWithConfiguration:(BTConfiguration *)configuration isBillingAgreement:(BOOL)isBillingAgreement {
    NSMutableDictionary *parameters = [[super parametersWithConfiguration:configuration isBillingAgreement:NO] mutableCopy];

    parameters[@"intent"] = self.intentAsString;
    parameters[@"amount"] = self.amount;
    parameters[@"offer_pay_later"] = @(self.offerPayLater);

    NSString *currencyCode = self.currencyCode ?: [configuration.json[@"paypal"][@"currencyIsoCode"] asString];
    if (currencyCode) {
        parameters[@"currency_iso_code"] = currencyCode;
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

@end
