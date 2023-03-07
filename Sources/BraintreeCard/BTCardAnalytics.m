#import "BTCardAnalytics_Internal.h"

@implementation BTCardAnalytics

+ (NSString *)cardTokenizeStarted {
    return @"card:tokenize:started";
}

+ (NSString *)cardTokenizeFailed {
    return @"card:tokenize:failed";
}

+ (NSString *)cardTokenizeSucceeded {
    return @"card:tokenize:succeeded";
}

+ (NSString *)cardTokenizeNetworkConnectionLost {
    return @"card:tokenize:network-connection:failed";
}

@end
