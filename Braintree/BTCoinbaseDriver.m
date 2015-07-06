#import "BTCoinbaseDriver.h"

@implementation BTCoinbaseDriver

- (nonnull instancetype)initWithAPIClient:(nonnull BTAPIClient *)apiClient {
    return [super init];
}

- (void)authorizeAccountWithCompletion:(nonnull void (^)(BTTokenizedCoinbaseAccount * __nullable, NSError * __nullable))completionBlock {
    // TODO
}

@end
