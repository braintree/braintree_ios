#import <Foundation/Foundation.h>
#import "BTNullability.h"
#import "BTTokenized.h"

BT_ASSUME_NONNULL_BEGIN

/// Objects that conform to this interface are placeholders for sensitive payments data that has been uplaoded to Braintree for subsequent processing
///
/// The paymentMethodNonce is the public token that is safe to access on the client but can be used
/// on your server to reference the data in Braintree operations, such as Transaction.Sale.
@protocol BTTokenized <NSObject>

@property (nonatomic, readonly, copy) NSString *paymentMethodNonce;
@property (nonatomic, readonly, copy) NSString *localizedDescription;

@end

BT_ASSUME_NONNULL_END
