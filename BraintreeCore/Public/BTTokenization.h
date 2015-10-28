#import "BTPaymentMethodNonce.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A concrete implementation of `BTPaymentMethodNonce` that implements the interface and nothing more.
///
/// This class is for generic tokenized payment information. For example, if a customer's vaulted payment methods contains
/// a type that's not recognized or supported by the Braintree SDK or the client-side integration (e.g. the vault contains
/// a PayPal account but the client-side integration does not include the PayPal component), this type can act as a fallback.
@interface BTTokenization : NSObject <BTPaymentMethodNonce>

- (nullable instancetype)initWithNonce:(NSString *)nonce localizedDescription:(nullable NSString *)description;

@end

NS_ASSUME_NONNULL_END
