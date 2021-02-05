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
        _offerPayLater = NO;
        _shippingAddressEditable = NO;
        _intent = BTPayPalRequestIntentAuthorize;
        _userAction = BTPayPalRequestUserActionDefault;
        _landingPageType = BTPayPalRequestLandingPageTypeDefault;
    }
    return self;
}

- (instancetype)initWithAmount:(NSString *)amount {
    if (amount == nil) {
        return nil;
    }

    if (self = [self init]) {
        _amount = amount;
    }
    return self;
}

- (NSDictionary<NSString *, NSObject *> *)parametersWithConfiguration:(BTConfiguration *)configuration isBillingAgreement:(BOOL)isBillingAgreement {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSMutableDictionary *experienceProfile = [NSMutableDictionary dictionary];

    if (!isBillingAgreement) {
        parameters[@"intent"] = [self intentTypeToString:self.intent];
        if (self.amount != nil) {
            parameters[@"amount"] = self.amount;
        }
    } else if (self.billingAgreementDescription.length > 0) {
        parameters[@"description"] = self.billingAgreementDescription;
    }

    parameters[@"offer_paypal_credit"] = @(self.offerCredit);

    parameters[@"offer_pay_later"] = @(self.offerPayLater);

    experienceProfile[@"no_shipping"] = @(!self.isShippingAddressRequired);

    experienceProfile[@"brand_name"] = self.displayName ?: [configuration.json[@"paypal"][@"displayName"] asString];

    NSString *landingPageTypeValue = [self landingPageTypeToString:self.landingPageType];
    if (landingPageTypeValue != nil) {
        experienceProfile[@"landing_page_type"] = landingPageTypeValue;
    }

    if (self.localeCode != nil) {
        experienceProfile[@"locale_code"] = self.localeCode;
    }

    if (self.merchantAccountId != nil) {
        parameters[@"merchant_account_id"] = self.merchantAccountId;
    }

    // Currency code should only be used for Hermes Checkout (one-time payment).
    // For BA, currency should not be used.
    NSString *currencyCode = self.currencyCode ?: [configuration.json[@"paypal"][@"currencyIsoCode"] asString];
    if (!isBillingAgreement && currencyCode) {
        parameters[@"currency_iso_code"] = currencyCode;
    }

    if (self.shippingAddressOverride != nil) {
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
        } else {
            parameters[@"line1"] = shippingAddress.streetAddress;
            parameters[@"line2"] = shippingAddress.extendedAddress;
            parameters[@"city"] = shippingAddress.locality;
            parameters[@"state"] = shippingAddress.region;
            parameters[@"postal_code"] = shippingAddress.postalCode;
            parameters[@"country_code"] = shippingAddress.countryCodeAlpha2;
            parameters[@"recipient_name"] = shippingAddress.recipientName;
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

- (NSString *)intentTypeToString:(BTPayPalRequestIntent)intentType {
    NSString *result = nil;

    switch(intentType) {
        case BTPayPalRequestIntentAuthorize:
            result = @"authorize";
            break;
        case BTPayPalRequestIntentSale:
            result = @"sale";
            break;
        case BTPayPalRequestIntentOrder:
            result = @"order";
            break;
        default:
            result = @"authorize";
            break;
    }

    return result;
}

- (NSString *)landingPageTypeToString:(BTPayPalRequestLandingPageType)landingPageType {
    switch(landingPageType) {
        case BTPayPalRequestLandingPageTypeLogin:
            return @"login";
        case BTPayPalRequestLandingPageTypeBilling:
            return @"billing";
        default:
            return nil;
    }
}

@end
