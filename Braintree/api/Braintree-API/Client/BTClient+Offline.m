#import "BTClient+Offline.h"
#import "BTClientToken.h"
#import "BTOfflineModeURLProtocol.h"
#import "BTOfflineClientBackend.h"

@implementation BTClient (Offline)

+ (NSString *)offlineTestClientTokenWithAdditionalParameters:(NSDictionary *)configuration {
    NSMutableDictionary *clientTokenDataDictionary =
    [NSMutableDictionary dictionaryWithDictionary:@{ BTClientTokenKeyAuthorizationFingerprint: @"an_authorization_fingerprint",
                                                     BTClientTokenKeyClientApiURL: BTOfflineModeClientApiBaseURL }];

    [clientTokenDataDictionary addEntriesFromDictionary:configuration];

    NSData *clientTokenData = [NSJSONSerialization dataWithJSONObject:clientTokenDataDictionary
                                                              options:0
                                                                error:NULL];
    NSString *clientToken = [[NSString alloc] initWithData:clientTokenData
                                                  encoding:NSUTF8StringEncoding];

    [BTOfflineModeURLProtocol setBackend:[BTOfflineClientBackend new]];

    return clientToken;
}

@end
