#import "BTNullability.h"
#import "BTTokenized.h"
#import <Foundation/Foundation.h>

BT_ASSUME_NONNULL_BEGIN

/// A concrete implementation of `BTTokenized` that implements the interface and nothing more.
///
/// This class is for generic tokenized payment information. For example, if a customer's vaulted payment methods contains
/// a type that's not recognized or supported by the Braintree SDK or the client-side integration (e.g. the vault contains
/// a PayPal account but the client-side integration does not include the PayPal component), this type can act as a fallback.
@interface BTTokenization : NSObject <BTTokenized>

- (BT_NULLABLE instancetype)initWithNonce:(NSString *)nonce localizedDescription:(BT_NULLABLE NSString *)description;

@end

BT_ASSUME_NONNULL_END
