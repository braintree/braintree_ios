#import "BTApplePayTokenizationClient.h"

BT_ASSUME_NONNULL_BEGIN

@implementation BTApplePayTokenizationClient

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    // TODO
    return [super init];
}

- (void)tokenizeApplePayPayment:(PKPayment *)payment completion:(void (^)(BTTokenizedApplePayPayment * __BT_NULLABLE, NSError * __BT_NULLABLE))completionBlock {
    // TODO
}

@end

BT_ASSUME_NONNULL_END
