#import "BTPayPalRequest_Internal.h"

#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalLineItem.h>
#else
#import <BraintreePayPal/BTPayPalLineItem.h>
#endif

NSString *const BTPayPalCallbackURLHostAndPath = @"onetouch/v1/";
NSString *const BTPayPalCallbackURLScheme = @"sdk.ios.braintree";

@implementation BTPayPalRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shippingAddressRequired = NO;
        _offerCredit = NO;
        _shippingAddressEditable = NO;
        _userAction = BTPayPalRequestUserActionDefault;
        _landingPageType = BTPayPalRequestLandingPageTypeDefault;
    }
    return self;
}

- (NSDictionary<NSString *, NSObject *> *)parametersWithConfiguration:(BTConfiguration *)configuration isBillingAgreement:(BOOL)isBillingAgreement {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSMutableDictionary *experienceProfile = [NSMutableDictionary dictionary];

    if (isBillingAgreement && self.billingAgreementDescription.length > 0) {
        parameters[@"description"] = self.billingAgreementDescription;
    }

    parameters[@"offer_paypal_credit"] = @(self.offerCredit);

    experienceProfile[@"no_shipping"] = @(!self.isShippingAddressRequired);

    experienceProfile[@"brand_name"] = self.displayName ?: [configuration.json[@"paypal"][@"displayName"] asString];

    if (self.landingPageTypeAsString) {
        experienceProfile[@"landing_page_type"] = self.landingPageTypeAsString;
    }

    if (self.localeCode) {
        experienceProfile[@"locale_code"] = self.localeCode;
    }

    if (self.merchantAccountId) {
        parameters[@"merchant_account_id"] = self.merchantAccountId;
    }

    if (self.shippingAddressOverride) {
        experienceProfile[@"address_override"] = @(!self.isShippingAddressEditable);
        BTPostalAddress *shippingAddress = self.shippingAddressOverride;
        if (isBillingAgreement) {
            NSMutableDictionary *shippingAddressParams = [NSMutableDictionary dictionary];
            shippingAddressParams[@"line1"] = shippingAddress.streetAddress;
            shippingAddressParams[@"line2"] = shippingAddress.extendedAddress;
            shippingAddressParams[@"city"] = shippingAddress.locality;
            shippingAddressParams[@"state"] = shippingAddress.region;
            shippingAddressParams[@"postal_code"] = shippingAddress.postalCode;
            shippingAddressParams[@"country_code"] = shippingAddress.countryCodeAlpha2;
            shippingAddressParams[@"recipient_name"] = shippingAddress.recipientName;
            parameters[@"shipping_address"] = shippingAddressParams;
        }
    } else {
        experienceProfile[@"address_override"] = @NO;
    }

    if (self.lineItems.count > 0) {
        NSMutableArray *lineItemsArray = [NSMutableArray arrayWithCapacity:self.lineItems.count];
        for (BTPayPalLineItem *lineItem in self.lineItems) {
            [lineItemsArray addObject:[lineItem requestParameters]];
        }

        parameters[@"line_items"] = lineItemsArray;
    }

    parameters[@"return_url"] = [NSString stringWithFormat:@"%@://%@success", BTPayPalCallbackURLScheme, BTPayPalCallbackURLHostAndPath];
    parameters[@"cancel_url"] = [NSString stringWithFormat:@"%@://%@cancel", BTPayPalCallbackURLScheme, BTPayPalCallbackURLHostAndPath];
    parameters[@"experience_profile"] = experienceProfile;

    return parameters;
}

- (NSString *)landingPageTypeAsString {
    switch(self.landingPageType) {
        case BTPayPalRequestLandingPageTypeLogin:
            return @"login";
        case BTPayPalRequestLandingPageTypeBilling:
            return @"billing";
        default:
            return nil;
    }
}

@end
