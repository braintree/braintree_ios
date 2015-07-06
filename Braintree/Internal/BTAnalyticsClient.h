#import <Foundation/Foundation.h>
#import "BTAPIClient.h"

@interface BTAnalyticsClient : NSObject

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

- (void)postAnalyticsEvent:(NSString *)name;

@end
