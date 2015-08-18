#import "BTPaymentOption.h"

BT_ASSUME_NONNULL_BEGIN

@implementation BTPaymentOption

+ (instancetype)cards {
    // TODO
    return nil;
}

+ (instancetype)payPalAuthoriztion {
    // TODO
    return nil;
}

+ (instancetype)payPalCheckout {
    // TODO
    return nil;
}

+ (instancetype)coinbase {
    // TODO
    return nil;
}

+ (instancetype)threeDSecureCards {
    // TODO
    return nil;
}

+ (instancetype)applePay {
    // TODO
    return nil;
}

+ (instancetype)venmo {
    // TODO
    return nil;
}

- (instancetype)initWithLabel:(NSString *)label action:(void (^)(id<BTTokenized> __BT_NULLABLE, NSError * __BT_NULLABLE))actionBlock {
    // TODO
    return [super init];
}

- (instancetype)init {
    // TODO
    return [self initWithLabel:@""
                        action:^(id<BTTokenized>  __BT_NULLABLE tokenizedPaymentMethod, NSError * __BT_NULLABLE error) {
                            // TODO
                        }];
}

@end

BT_ASSUME_NONNULL_END
