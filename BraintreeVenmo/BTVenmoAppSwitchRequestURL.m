#import <UIKit/UIKit.h>

#import "BTVenmoAppSwitchRequestURL.h"

#if __has_include("BraintreeCore.h")
#import "BTURLUtils.h"
#else
#import <BraintreeCore/BTURLUtils.h>
#endif

#define kXCallbackTemplate @"scheme://x-callback-url/path"
#define kVenmoScheme @"com.venmo.touch.v2"

@implementation BTVenmoAppSwitchRequestURL

+ (NSURL *)baseAppSwitchURL {
    return [self appSwitchBaseURLComponents].URL;
}

+ (NSURL *)appSwitchURLForMerchantID:(NSString *)merchantID
                 accessToken:(NSString *)accessToken
                          sdkVersion:(NSString *)sdkVersion
                     returnURLScheme:(NSString *)scheme
                   bundleDisplayName:(NSString *)bundleName
                         environment:(NSString *)environment
{
    NSMutableDictionary *appSwitchParameters = [@{@"x-success": [self returnURLWithScheme:scheme result:@"success"],
                                                  @"x-error": [self returnURLWithScheme:scheme result:@"error"],
                                                  @"x-cancel": [self returnURLWithScheme:scheme result:@"cancel"],
                                                  @"x-source": bundleName,
                                                  @"braintree_merchant_id": merchantID,
                                                  @"braintree_access_token": accessToken,
                                                  @"braintree_sdk": sdkVersion,
                                                  @"braintree_environment": environment,
                                                  } mutableCopy];

    NSURLComponents *components = [self appSwitchBaseURLComponents];
    components.percentEncodedQuery = [BTURLUtils queryStringWithDictionary:appSwitchParameters];
    return components.URL;
}

#pragma mark Internal Helpers

+ (NSURL *)returnURLWithScheme:(NSString *)scheme result:(NSString *)result {
    NSURLComponents *components = [NSURLComponents componentsWithString:kXCallbackTemplate];
    components.scheme = scheme;
    components.percentEncodedPath = [NSString stringWithFormat:@"/vzero/auth/venmo/%@", result];
    return components.URL;
}

+ (NSURLComponents *)appSwitchBaseURLComponents {
    NSURLComponents *components = [NSURLComponents componentsWithString:kXCallbackTemplate];
    components.scheme = kVenmoScheme;
    components.percentEncodedPath = @"/vzero/auth";
    return components;
}

@end
