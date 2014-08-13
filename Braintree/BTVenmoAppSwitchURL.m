//
//  BTVenmoAppSwitchURL.m
//  Braintree
//
//  Created by Mickey Reiss on 8/12/14.
//
//

#import "BTVenmoAppSwitchURL.h"
#import "BTURLUtils.h"

@implementation BTVenmoAppSwitchURL

+ (BOOL)isAppSwitchAvailable {
    // We have a return URL registered
    // Venmo app that registers the URL is present
    return NO;
}

+ (NSURL *)appSwitchURLForMerchantID:(NSString *)merchantID {
    NSDictionary *appSwitchParameters = @{
                                          @"x-success": @"com.braintreepayments.Braintree-Demo.payments://x-callback-url/vzero/auth/venmo/success",
                                          @"x-error": @"com.braintreepayments.Braintree-Demo.payments://x-callback-url/vzero/auth/venmo/error",
                                          @"x-cancel": @"com.braintreepayments.Braintree-Demo.payments://x-callback-url/vzero/auth/venmo/cancel",
                                          @"x-source": @"Braintree Demo",
                                          @"braintree_merchant_id": merchantID
                                          };

    NSURL *venmoAppSwitchURL = [[NSURL URLWithString:@"com.venmo.touch.v1://x-callback-url/vzero/auth"] uq_URLByAppendingQueryDictionary:appSwitchParameters];

    return venmoAppSwitchURL;
}

@end
