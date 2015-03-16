#import "BTClient+Offline.h"
#import "BTClientToken.h"
#import "BTOfflineModeURLProtocol.h"
#import "BTOfflineClientBackend.h"
#import "BTConfiguration.h"

@implementation BTClient (Offline)

+ (NSString *)offlineTestClientTokenWithAdditionalParameters:(NSDictionary *)overrides {
    NSMutableDictionary *clientTokenDataDictionary =
    [NSMutableDictionary dictionaryWithDictionary:@{BTClientTokenKeyVersion: @2,
                                                    BTClientTokenKeyAuthorizationFingerprint: @"an_authorization_fingerprint",
                                                    BTClientTokenKeyConfigURL: [BTOfflineModeClientApiBaseURL stringByAppendingString:@"/configuration"],
                                                    // New BTConfiguration constants are the same as the BTClientToken ones were;
                                                    // Ensure that old behavior still works.
                                                    BTConfigurationKeyClientApiURL: BTOfflineModeClientApiBaseURL,
                                                    BTConfigurationKeyApplePay: @{
                                                            BTConfigurationKeyStatus: @"mock",
                                                            @"countryCode": @"US",
                                                            @"currencyCode": @"USD",
                                                            @"merchantIdentifier": @"merchant-id-apple-pay",
                                                            @"supportedNetworks": @[
                                                                    @"visa",
                                                                    @"mastercard",
                                                                    @"amex"
                                                                    ]
                                                            }
                                                    }];

    [clientTokenDataDictionary addEntriesFromDictionary:overrides];

    NSData *clientTokenData = [NSJSONSerialization dataWithJSONObject:clientTokenDataDictionary
                                                              options:0
                                                                error:NULL];
    NSString *clientToken = [clientTokenData base64EncodedStringWithOptions:0];
    [BTOfflineModeURLProtocol setBackend:[BTOfflineClientBackend new]];

    return clientToken;
}

@end
