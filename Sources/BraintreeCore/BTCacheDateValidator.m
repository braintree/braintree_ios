#import <Foundation/Foundation.h>
#import "BTCacheDateValidator_Internal.h"


@implementation BTCacheDateValidator : NSObject

- (instancetype)init {
    _timeToLiveMinutes = 5;
    return self;
}

-(BOOL) isCacheInvalid:(NSCachedURLResponse *)cachedConfigurationResponse {
    NSDate *currentTimestamp = [[NSDate alloc] init];
    // Invalidate cached configuration after 5 minutes
    NSDate *invalidCacheTimestamp = [currentTimestamp dateByAddingTimeInterval:-60*_timeToLiveMinutes];
    
    NSHTTPURLResponse *cachedResponse = (NSHTTPURLResponse*)cachedConfigurationResponse.response;
    
    NSString *cachedResponseDateString = cachedResponse.allHeaderFields[@"Date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"];
    NSDate *cachedResponseDate = [dateFormatter dateFromString:cachedResponseDateString];
    
    NSDate *earlierDate = [cachedResponseDate earlierDate:invalidCacheTimestamp];
    
    return [earlierDate isEqualToDate:cachedResponseDate];
}

@end
