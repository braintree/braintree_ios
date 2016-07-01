#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BTPostalAddress.h"
#else
#import <BraintreeCore/BTPostalAddress.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTDropInRequest : NSObject <NSCopying>

/// Optional: Amount of the transaction.
///
/// Amount must be a non-negative number, may optionally contain exactly 2 decimal places
/// separated by '.', optional thousands separator ',', limited to 7 digits before the decimal point.
///
/// Used by PayPal.
@property (nonatomic, copy, nullable) NSString *amount;

/// Optional: A valid ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
///
/// Used by PayPal.
@property (nonatomic, copy, nullable) NSString *currencyCode;

/// Defaults to false. When set to true, the shipping address selector will not be displayed.
///
/// Used by PayPal.
@property (nonatomic, assign) BOOL noShipping;

/// Optional: A valid shipping address to be displayed in the transaction flow.
/// An error will occur if this address is not valid.
///
/// Used by PayPal.
@property (nonatomic, strong, nullable) BTPostalAddress *shippingAddress;

/// Optional: A set of PayPal scopes to use when requesting payment via PayPal. Used by Drop-in and payment button.
@property (nonatomic, strong, nullable) NSSet<NSString *> *additionalPayPalScopes;

/// Optional: If true and Apple Pay is correctly configured, Apple Pay will appear as a selection in the Payment Method options.
///
/// @note Set to the result of [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:]
@property (nonatomic, assign) BOOL canMakeApplePayPayments;

@end

NS_ASSUME_NONNULL_END
