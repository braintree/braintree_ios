#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// A PayPal request specifies options that control the PayPal flow.
///
/// For a one-time payment, the request must specify a transaction amount.
///
/// @see BTPayPalDriver
@interface BTPayPalRequest : NSObject

/// Initialize a PayPal request with an amount for a one-time payment.
///
/// @param amount Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.', optional thousands separator ',', and is limited to 7 digits before the decimal point.
/// @return A PayPal request.
- (instancetype)initWithAmount:(NSString *)amount;

/// Used for a one-time payment.
///
/// Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.', optional thousands separator ',', and is limited to 7 digits before the decimal point.
@property (nonatomic, readonly, strong) NSString *amount;

/// Defaults to false. When set to true, the shipping address selector will be displayed.
@property (nonatomic, getter=isShippingAddressRequired) BOOL shippingAddressRequired;

/// Optional: A valid ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
/// @note This is only used for one-time payments.
@property (nonatomic, nullable, copy) NSString *currencyCode;

/// Optional: A locale code to use for the transaction.
@property (nonatomic, nullable, copy) NSString *localeCode;

/// Optional: A valid shipping address to be displayed in the transaction flow. An error will occur if this address is not valid.
@property (nonatomic, nullable, strong) BTPostalAddress *shippingAddressOverride;

/// Optional: Display a custom description to the user for a billing agreement.
@property (nonatomic, nullable, copy) NSString *billingAgreementDescription;

@end

NS_ASSUME_NONNULL_END
