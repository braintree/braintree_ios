#import "BTCardAnalytics.h"

@implementation BTCardAnalytics

@dynamic cardTokenizeStarted;
- (NSString *)cardTokenizeStarted {
    return @"card:tokenize:started";
}

@dynamic cardTokenizeFailed;
- (NSString *)cardTokenizeFailed {
    return @"card:tokenize:failed";
}

@dynamic cardTokenizeSucceeded;
- (NSString *)cardTokenizeSucceeded {
    return @"card:tokenize:succeeded";
}

@dynamic cardTokenizeNetworkConnectionLost;
- (NSString *)cardTokenizeNetworkConnectionLost {
    return @"card:tokenize:network-connection:failed";
}


@end
