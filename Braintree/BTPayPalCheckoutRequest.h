#import <Foundation/Foundation.h>
#import "BTNullability.h"

BT_ASSUME_NONNULL_BEGIN

/// A PayPal checkout request encapsulates a set of options that control a user-facing PayPal checkout flow.
///
/// A checkout request must specify, at minimum, an anticipated transaction amount.
///
/// @see BTPayPalDriver
@interface BTPayPalCheckoutRequest : NSObject

+ (nullable instancetype)checkoutWithAmount:(NSDecimalNumber *)amount error:(NSError **)error;

+ (nullable instancetype)checkoutWithAmount:(NSDecimalNumber *)amount merchantAccount:(NSString *)merchantAccount error:(NSError **)error;

/// @name Properties

@property (nonatomic, assign) BOOL enableShippingAddress;

@end

BT_ASSUME_NONNULL_END
