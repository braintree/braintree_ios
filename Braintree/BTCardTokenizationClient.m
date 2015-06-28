#import "BTCardTokenizationClient.h"

@implementation BTCardTokenizationClient

- (nonnull instancetype)initWithConfiguration:(nonnull BTConfiguration *)configuration {
    self = [self init];
    return self;
}

- (void)tokenizeCard:(nonnull BTCard *)card completion:(nonnull void (^)(BTTokenizedCard * __nullable, NSError * __nullable))completionBlock {
    // TODO
}

@end
