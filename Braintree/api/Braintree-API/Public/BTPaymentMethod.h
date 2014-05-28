#import <Foundation/Foundation.h>

/// A payment method returned by the Client API that represents a payment method associated with
/// a particular Braintree customer.
///
/// See also: BTCard and BTPayPalAccount.
@interface BTPaymentMethod : NSObject

/// Unique token that, if unlocked, may be used to create payments
///
/// Pass this value to the server for use as the `payment_method_nonce`
/// argument of Braintree server-side client library methods.
@property (nonatomic, readonly, copy) NSString *nonce;

/// Indicates whether the payment method must be unlocked to be used, for example, in `Transaction.Create`.
@property (nonatomic, readonly, assign, getter = isLocked) BOOL locked;

/// Set of challenge questions required to unlock a payment method.
@property (nonatomic, readonly, strong) NSSet *challengeQuestions;

@end
