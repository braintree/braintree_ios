#import "BTCoinbaseDriver.h"

@implementation BTCoinbaseDriver

- (nonnull instancetype)initWithConfiguration:(nonnull BTConfiguration *)configuration {
    return [super init];
}

- (void)authorizeAccountWithCompletion:(nonnull void (^)(BTTokenizedCoinbaseAccount * __nullable, NSError * __nullable))completionBlock {
    // TODO
}

@end
