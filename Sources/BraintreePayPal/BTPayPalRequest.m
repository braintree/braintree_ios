#import "BTPayPalRequest_Internal.h"

#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BraintreePayPal-Swift.h>
#else
#import <BraintreePayPal/BraintreePayPal-Swift.h>
#endif

// MARK: - Swift File Imports for Package Managers
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

    if (self.riskCorrelationId) {
        parameters[@"correlation_id"] = self.riskCorrelationId;
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
