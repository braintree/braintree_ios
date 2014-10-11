@import PassKit;

#import "BTPaymentMethod.h"

/// The server-side resource that represents a payment method created via Apple Pay.
@interface BTApplePayPaymentMethod : BTPaymentMethod <NSCopying, NSMutableCopying>

// TODO: Add tests around copying and mutable copying this property
@property (nonatomic, readonly) ABRecordRef billingAddress;

// TODO: Add tests around copying and mutable copying this property
@property (nonatomic, readonly) ABRecordRef shippingAddress;

// TODO: Add tests around copying and mutable copying this property
@property (nonatomic, strong, readonly) PKShippingMethod *shippingMethod;

@end
