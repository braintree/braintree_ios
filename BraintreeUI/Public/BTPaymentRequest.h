#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BTPostalAddress.h"
#else
#import <BraintreeCore/BTPostalAddress.h>
#endif

@class BTAPIClient;

NS_ASSUME_NONNULL_BEGIN

@interface BTPaymentRequest : NSObject <NSCopying>

/// Primary text to display in the summary view.
///
/// Intended to provide a name the overall transaction taking place. For example, "1 Item", "1 Year Subscription", "Yellow T-Shirt", etc.
///
/// If summaryTitle or summaryDescription are nil, then the summary view is not shown.
@property (nonatomic, copy, nullable) NSString *summaryTitle;

/// Detail text to display in the summary view.
///
/// Intended to provide a few words of detail. For example, "Ships in Five Days", "15 feet by 12 feet" or "We know you'll love it"
///
/// If summaryTitle or summaryDescription are nil, then the summary view is not shown.
@property (nonatomic, copy, nullable) NSString *summaryDescription;

/// A string representation of the grand total amount
///
/// For example, "$12.95"
@property (nonatomic, copy) NSString *displayAmount;

/// The text to display in the primary call-to-action button. For example: "$19 - Purchase" or "Subscribe Now".
@property (nonatomic, copy) NSString *callToActionText;

/// Whether to hide the call to action control in Drop-in's content view.
///
/// When `YES`, the call to action control in Drop-in's content view will be hidden;
/// instead, a submit button will be added as a bar button item, which relies on the
/// Drop-in view controller being embedded in a navigation controller.
///
/// Defaults to `NO`, so that the call to action control will be shown within Drop-in's
/// content view.
///
/// @see callToAction
/// @see callToActionAmount
@property (nonatomic, assign) BOOL shouldHideCallToAction;

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

@end

NS_ASSUME_NONNULL_END
