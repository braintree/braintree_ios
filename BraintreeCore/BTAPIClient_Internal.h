#import "BTAPIClient.h"
#import "BTClientMetadata.h"
#import "BTJSON.h"
#import "BTHTTP.h"

@interface BTAPIClient ()
@property (nonatomic, copy) NSString *clientKey;
@property (nonatomic, copy) NSString *clientJWT;
@property (nonatomic, strong) BTHTTP *http;

/// Client metadata that is used for tracking the client session
@property (nonatomic, readonly, strong) BTClientMetadata *metadata;

/// Exposed for testing to verify interaction between analytics client and the network
@property (nonatomic, strong) BTHTTP *analyticsHttp;

/// Analytics should only be posted by internal clients?
- (void)postAnalyticsEvent:(NSString *)name;

/// Exposed to provide a more testable API for sending analytics, since it involves asynchronous operations
- (void)postAnalyticsEvent:(NSString *)name completion:(void(^)(NSError *error))completionBlock;

@end
