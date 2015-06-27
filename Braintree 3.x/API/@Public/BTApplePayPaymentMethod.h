#if BT_ENABLE_APPLE_PAY
@import PassKit;

#import "BTPaymentMethod.h"

/// The server-side resource that represents a payment method created via Apple Pay.
@interface BTApplePayPaymentMethod : BTPaymentMethod <NSCopying, NSMutableCopying>

@property (nonatomic, readonly) ABRecordRef billingAddress;
@property (nonatomic, readonly) ABRecordRef shippingAddress;
@property (nonatomic, strong, readonly) PKShippingMethod *shippingMethod;

@end
#endif
