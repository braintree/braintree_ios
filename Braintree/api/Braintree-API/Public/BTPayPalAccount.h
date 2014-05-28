#import "BTPaymentMethod.h"

/// A payment method returned by the Client API that represents a PayPal account associated with
/// a particular Braintree customer.
///
/// @see BTPaymentMethod
/// @see BTMutablePayPalAccount
@interface BTPayPalAccount : BTPaymentMethod

/// Email address associated with the PayPal Account.
@property (nonatomic, readonly, copy) NSString *email;

@end
