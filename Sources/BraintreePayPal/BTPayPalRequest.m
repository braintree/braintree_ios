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
        _shippingAddressEditable = NO;
        _landingPageType = BTPayPalRequestLandingPageTypeDefault;
    }
    return self;
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

- (NSDictionary<NSString *, NSObject *> *)parametersWithConfiguration:(BTConfiguration *)configuration {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSMutableDictionary *experienceProfile = [NSMutableDictionary dictionary];

    experienceProfile[@"no_shipping"] = @(!self.isShippingAddressRequired);

    experienceProfile[@"brand_name"] = self.displayName ?: [configuration.json[@"paypal"][@"displayName"] asString];

    if (self.landingPageTypeAsString) {
        experienceProfile[@"landing_page_type"] = self.landingPageTypeAsString;
    }

    if (self.localeCode) {
        experienceProfile[@"locale_code"] = self.localeCode;
    }

    if (self.merchantAccountID) {
        parameters[@"merchant_account_id"] = self.merchantAccountID;
    }

    if (self.shippingAddressOverride) {
        experienceProfile[@"address_override"] = @(!self.isShippingAddressEditable);
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

@end
