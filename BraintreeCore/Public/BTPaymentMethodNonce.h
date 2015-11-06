#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// BTPaymentMethodNonce is for generic tokenized payment information.
///
/// For example, if a customer's vaulted payment methods contains a type that's not recognized or supported by the
/// Braintree SDK or the client-side integration (e.g. the vault contains a PayPal account but the client-side
/// integration does not include the PayPal component), this type can act as a fallback.
///
/// The payment method nonce is a public token that acts as a placeholder for sensitive payments data that
/// has been uploaded to Braintree for subsequent processing. The nonce is safe to access on the client and can be
/// used on your server to reference the data in Braintree operations, such as Transaction.sale.
@interface BTPaymentMethodNonce : NSObject

- (nullable instancetype)initWithNonce:(NSString *)nonce localizedDescription:(nullable NSString *)description;

/// The one-time use payment method nonce
@property (nonatomic, readonly, copy) NSString *nonce;

/// A localized description of the payment info
@property (nonatomic, readonly, copy) NSString *localizedDescription;

/// The type of the tokenized data, e.g. PayPal, Venmo, MasterCard, Visa, Amex
@property (nonatomic, readonly, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
