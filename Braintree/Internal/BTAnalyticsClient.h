#import <Foundation/Foundation.h>
#import "BTConfiguration.h"

@interface BTAnalyticsClient : NSObject

- (instancetype)initWithConfiguration:(BTConfiguration *)configuration;

- (void)postAnalyticsEvent:(NSString *)name;

@end
