#import <Foundation/Foundation.h>

/// A payment method returned by the Client API that represents a payment method associated with
/// a particular Braintree customer.
///
/// See also: BTCardPaymentMethod and BTPayPalPaymentMethod.
@interface BTPaymentMethod : NSObject

/// Unique token that, if unlocked, may be used to create payments
///
/// Pass this value to the server for use as the `payment_method_nonce`
/// argument of Braintree server-side client library methods.
@property (nonatomic, readonly, copy) NSString *nonce;

@end
