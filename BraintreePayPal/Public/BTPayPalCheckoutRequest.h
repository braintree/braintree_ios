#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// A PayPal Checkout Request specifies options that control a user-facing PayPal checkout flow.
///
/// A Checkout Request must specify an anticipated transaction amount.
///
/// @see BTPayPalDriver
@interface BTPayPalCheckoutRequest : NSObject

/// Initialize a Checkout Request with an amount.
///
/// Amount must be a non-negative number, may optionally contain exactly 2 decimal places separated by '.', optional thousands separator ',', limited to 7 digits before the decimal point.
///
/// @param amount An amount greater than or equal to zero. Used for single payment Checkout Requests.
/// @return A Checkout Request, or `nil` if the amount is `nil`.
- (nullable instancetype)initWithAmount:(NSString *)amount;

/// The amount - used for single payment Checkout Requests.
///
/// Amount must be a non-negative number, may optionally contain exactly 2 decimal places separated by '.', optional thousands separator ',', limited to 7 digits before the decimal point.
@property (nonatomic, readonly, strong) NSString *amount;

/// Defaults to false. When set to true, the shipping address selector will be displayed.
@property (nonatomic) BOOL shippingAddressRequired;

/// Optional: A valid ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
/// @note This is only used for one-time payments.
@property (nonatomic, nullable, copy) NSString *currencyCode;

/// Optional: A locale code to use for the transaction.
@property (nonatomic, nullable, copy) NSString *localeCode;

/// Optional: A valid shipping address to be displayed in the transaction flow. An error will occur if this address is not valid.
@property (nonatomic, nullable, strong) BTPostalAddress *shippingAddressOverride;

@end

NS_ASSUME_NONNULL_END
