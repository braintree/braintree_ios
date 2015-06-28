#import "BTApplePayTokenizationClient.h"

BT_ASSUME_NONNULL_BEGIN

@implementation BTApplePayTokenizationClient

- (instancetype)initWithConfiguration:(BTConfiguration *)configuration {
    // TODO
    return [super init];
}

- (void)tokenizeApplePayPayment:(PKPayment *)payment completion:(void (^)(BTTokenizedApplePayPaymentMethod * __BT_NULLABLE, NSError * __BT_NULLABLE))completionBlock {
    // TODO
}

@end

BT_ASSUME_NONNULL_END
