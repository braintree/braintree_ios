#import "BTAPIClient.h"
#import "BTClientMetadata.h"
#import "BTClientToken.h"
#import "BTJSON.h"
#import "BTHTTP.h"

@interface BTAPIClient ()
@property (nonatomic, copy) NSString *tokenizationKey;
@property (nonatomic, copy) NSString *clientJWT;
@property (nonatomic, strong) BTClientToken *clientToken;
@property (nonatomic, strong) BTHTTP *http;

/// Client metadata that is used for tracking the client session
@property (nonatomic, readonly, strong) BTClientMetadata *metadata;

/// Exposed for testing to verify interaction between analytics client and the network
@property (nonatomic, strong) BTHTTP *analyticsHttp;

/// Analytics should only be posted by internal clients.
- (void)sendAnalyticsEvent:(NSString *)eventName;

/// Exposed to provide a more testable API for sending analytics, since it involves asynchronous operations
- (void)sendAnalyticsEvent:(NSString *)eventName completion:(void(^)(NSError *error))completionBlock;

@end
