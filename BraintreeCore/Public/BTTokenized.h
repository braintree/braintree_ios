#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Objects that conform to this interface are placeholders for sensitive payments data that has been uploaded to Braintree for subsequent processing
///
/// The paymentMethodNonce is the public token that is safe to access on the client but can be used
/// on your server to reference the data in Braintree operations, such as Transaction.Sale.
@protocol BTTokenized <NSObject>

/// The one-time use payment method nonce
@property (nonatomic, readonly, copy) NSString *paymentMethodNonce;
/// A localized description of the payment info
@property (nonatomic, readonly, copy) NSString *localizedDescription;
/// The type of the tokenized data, e.g. PayPal, Venmo, MasterCard, Visa, Amex
@property (nonatomic, readonly, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
