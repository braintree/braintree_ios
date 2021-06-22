#import "BTVenmoAppSwitchRequestURL.h"

#if __has_include(<Braintree/BraintreeVenmo.h>) // CocoaPods
#import <Braintree/BraintreeCore.h>
#import <Braintree/Braintree-Version.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreeCore/BraintreeCore.h>
#import "../BraintreeCore/Braintree-Version.h"

#else // Carthage
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCore/Braintree-Version.h>

#endif

#define kXCallbackTemplate @"scheme://x-callback-url/path"
#define kVenmoScheme @"com.venmo.touch.v2"

@implementation BTVenmoAppSwitchRequestURL

+ (NSURL *)baseAppSwitchURL {
    return [self appSwitchBaseURLComponents].URL;
}

+(NSURL *)appSwitchURLForMerchantID:(NSString *)merchantID
                        accessToken:(NSString *)accessToken
                    returnURLScheme:(NSString *)scheme
                  bundleDisplayName:(NSString *)bundleName
                        environment:(NSString *)environment
                   paymentContextID:(NSString *)paymentContextID
                           metadata:(BTClientMetadata *)metadata
{
    NSURL *successReturnURL = [self returnURLWithScheme:scheme result:@"success"];
    NSURL *errorReturnURL = [self returnURLWithScheme:scheme result:@"error"];
    NSURL *cancelReturnURL = [self returnURLWithScheme:scheme result:@"cancel"];
    if (!successReturnURL || !errorReturnURL || !cancelReturnURL || !accessToken || !metadata || !scheme || !bundleName || !environment || !merchantID) {
        return nil;
    }
    
    NSMutableDictionary *braintreeData = [@{@"_meta": @{
                                                    @"version": BRAINTREE_VERSION,
                                                    @"sessionId": [metadata sessionID],
                                                    @"integration": [metadata integrationString],
                                                    @"platform": @"ios"
                                                    }
                                            } mutableCopy];

    NSData *serializedBraintreeData = [NSJSONSerialization dataWithJSONObject:braintreeData options:0 error:NULL];
    NSString *base64EncodedBraintreeData = [serializedBraintreeData base64EncodedStringWithOptions:0];

    NSMutableDictionary *appSwitchParameters = [@{@"x-success": successReturnURL,
                                                  @"x-error": errorReturnURL,
                                                  @"x-cancel": cancelReturnURL,
                                                  @"x-source": bundleName,
                                                  @"braintree_merchant_id": merchantID,
                                                  @"braintree_access_token": accessToken,
                                                  @"braintree_environment": environment,
                                                  @"braintree_sdk_data": base64EncodedBraintreeData,
                                                  } mutableCopy];

    if (paymentContextID) {
        appSwitchParameters[@"resource_id"] = paymentContextID;
    }

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
