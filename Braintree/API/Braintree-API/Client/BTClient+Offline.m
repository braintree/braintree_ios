#import "BTClient+Offline.h"
#import "BTClientToken.h"
#import "BTOfflineModeURLProtocol.h"
#import "BTOfflineClientBackend.h"

@implementation BTClient (Offline)

+ (NSString *)offlineTestClientTokenWithAdditionalParameters:(NSDictionary *)configuration {
    NSMutableDictionary *clientTokenDataDictionary =
    [NSMutableDictionary dictionaryWithDictionary:@{ BTClientTokenKeyAuthorizationFingerprint: @"an_authorization_fingerprint",
                                                     BTClientTokenKeyClientApiURL: BTOfflineModeClientApiBaseURL,
                                                     BTClientTokenKeyConfigURL: [BTOfflineModeClientApiBaseURL stringByAppendingString:@"/configuration"],
                                                     BTClientTokenKeyVersion: @2,
                                                     BTClientTokenKeyApplePay: @{
                                                             BTClientTokenKeyStatus: @"mock",
                                                             @"countryCode": @"US",
                                                             @"currencyCode": @"USD",
                                                             @"merchantIdentifier": @"merchant-id-apple-pay",
                                                             @"supportedNetworks": @[
                                                                     @"visa",
                                                                     @"mastercard",
                                                                     @"amex"
                                                                     ]
                                                             } }];

    [clientTokenDataDictionary addEntriesFromDictionary:configuration];

    NSData *clientTokenData = [NSJSONSerialization dataWithJSONObject:clientTokenDataDictionary
                                                              options:0
                                                                error:NULL];
    NSString *clientToken = [clientTokenData base64EncodedStringWithOptions:0];
    [BTOfflineModeURLProtocol setBackend:[BTOfflineClientBackend new]];

    return clientToken;
}

@end
