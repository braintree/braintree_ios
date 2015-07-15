#import "BTAPIClient.h"
#import "BTNullability.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTAnalyticsClient : NSObject

- (BT_NULLABLE instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

- (void)postAnalyticsEvent:(NSString *)name;

@end

BT_ASSUME_NONNULL_END
