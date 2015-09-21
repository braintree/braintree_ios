#if BT_ENABLE_APPLE_PAY
@import PassKit;

#import "BTPaymentMethod.h"

/// The server-side resource that represents a payment method created via Apple Pay.
@interface BTApplePayPaymentMethod : BTPaymentMethod <NSCopying, NSMutableCopying>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, readonly) ABRecordRef billingAddress;
@property (nonatomic, readonly) ABRecordRef shippingAddress;
#pragma clang diagnostic pop
@property (nonatomic, readonly, strong) PKContact *billingContact;
@property (nonatomic, readonly, strong) PKContact *shippingContact;
@property (nonatomic, strong, readonly) PKShippingMethod *shippingMethod;

@end
#endif
