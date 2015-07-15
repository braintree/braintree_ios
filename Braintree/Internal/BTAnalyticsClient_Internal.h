#import "BTAnalyticsClient.h"
#import "BTHTTP.h"

@interface BTAnalyticsClient ()

/// Exposed for testing to verify interaction between analytics client and the network
@property (nonatomic, strong) BTHTTP *analyticsHttp;

/// Exposed to provide a more testable API for sending analytics, since it involves asynchronous operations
- (void)postAnalyticsEvent:(NSString *)name completion:(void(^)(NSError *error))completionBlock;

@end
