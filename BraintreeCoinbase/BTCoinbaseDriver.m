#import "BTCoinbaseDriver.h"
#import <BraintreeCore/BTTokenizationService.h>

@implementation BTCoinbaseDriver

- (nonnull instancetype)initWithAPIClient:(nonnull BTAPIClient *)apiClient {
    return [super init];
}

+ (void)initialize {
    [[BTTokenizationService sharedService] registerType:@"Coinbase" withTokenizationBlock:^(BTAPIClient *apiClient, NSDictionary *options, void (^completionBlock)(id<BTTokenized> tokenization, NSError *error)) {
        BTCoinbaseDriver *driver = [[BTCoinbaseDriver alloc] initWithAPIClient:apiClient];
        [driver authorizeAccountWithCompletion:completionBlock];
    }];
}

- (void)authorizeAccountWithCompletion:(nonnull void (^)(BTTokenizedCoinbaseAccount * __nullable, NSError * __nullable))completionBlock {
    // TODO
}

@end
