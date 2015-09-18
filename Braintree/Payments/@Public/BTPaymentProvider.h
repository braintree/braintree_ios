#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "BTPaymentProviderErrors.h"
#import "BTClient.h"
#import "BTPaymentMethod.h"
#import "BTPaymentMethodCreationDelegate.h"

/// Type of payment method creation
typedef NS_ENUM(NSInteger, BTPaymentProviderType) {
    /// Authorize via PayPal
    ///
    /// Supports BTPaymentAuthorizationOptionMechanismAppSwitch and BTPaymentAuthorizationOptionMechanismViewController.
    BTPaymentProviderTypePayPal = 0,

    /// Authorize via Venmo
    ///
    /// Supports BTPaymentAuthorizationOptionMechanismAppSwitch only.
    BTPaymentProviderTypeVenmo,

    /// Authorize via Apple Pay
    ///
    /// Supports BTPaymentAuthorizationOptionMechanismViewController only.
    BTPaymentProviderTypeApplePay,

    /// Authorize via Coinbase (beta)
    ///
    /// Supports BTPaymentAuthorizationOptionMechanismBrowserSwitch and BTPaymentAuthorizationOptionMechanismViewController.
    BTPaymentProviderTypeCoinbase,
};


/// Options for payment method creation
///
/// These options designate how to authorize the user for the given payment option (BTPaymentProviderType). Each payment option supports a subset of these, as specified above.
typedef NS_OPTIONS(NSInteger, BTPaymentMethodCreationOptions) {

    /// Authorize via an app-switch to the provider's app if the app is already installed.
    ///
    /// If the target app is not installed, this mechanism will fail.
    BTPaymentAuthorizationOptionMechanismAppSwitch = 1 << 0,

    /// Authorize via in-app view controller presentation.
    BTPaymentAuthorizationOptionMechanismViewController = 1 << 1,

    /// Authorize via the best possible mechanism.
    BTPaymentAuthorizationOptionMechanismAny =  BTPaymentAuthorizationOptionMechanismAppSwitch | BTPaymentAuthorizationOptionMechanismViewController
};

/// Status of the last (or ongoing) payment method creation
typedef NS_ENUM(NSInteger, BTPaymentProviderStatus) {
    /// The payment method was not created yet (default status)
    BTPaymentProviderStatusUninitialized = 0,

    /// Payment method created (either PayPal, Venmo or ApplePay)
    BTPaymentProviderStatusInitialized,

    /// The payment method creator, having obtained user payment details and/or user
    /// authorization, is now processing the results
    BTPaymentProviderStatusProcessing,

    /// Payment method failed with error
    BTPaymentProviderStatusError,

    /// Payment method creation is complete with success
    BTPaymentProviderStatusSuccess,

    /// The payment method creator has canceled
    BTPaymentProviderStatusCanceled
};

/// The BTPaymentProvider enables you to collect payment information from the user.
///
/// This class abstracts the various payment payment providers and authorization
/// techniques. After initialization, you must set a client and delegate before
/// calling `createPaymentMethod:`. The authorization may request (via the delegate)
/// that you present a view controller, e.g., a PayPal login screen. createPaymentMethod: may also
/// initiate an app switch if One Touch is available. (See also +[Braintree setReturnURLScheme:] and
/// +[Braintree handleOpenURL:sourceApplication:])
///
@interface BTPaymentProvider : NSObject

/// Initializes a payment provider
///
/// @param client The BTClient that is used for communicating with Braintree during payment method creation
///
/// @return An initialized payment provider
- (instancetype)initWithClient:(BTClient *)client;

- (id)init __attribute__((unavailable("Please use initWithClient:")));

/// BTClient to use during authorization
@property (nonatomic, strong) BTClient *client;

/// Delegate to receive messages during payment authorization process
@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;

/// Asynchronously create a payment method for the given payment type.
///
/// Shorthand for `[authorize:type options:BTPaymentAuthorizationOptionMechanismAny]`
///
/// When you invoke this method, a payment authorization flow will be initiated in order to
/// create a Venmo or PayPal payment methods. It may use One Touch (app switch) or accept identity
/// credentials in a view controller.
///
/// In the happy path, the delegate will receive lifecycle notifications, culminating with
/// paymentMethodCreator:didCreatePaymentMethod:. The payment method will include a payment method
/// nonce and any available metadata for your checkout confirmation UI.
///
/// The delegate's paymentAuthorizer:didFailWithError: will be invoked if
/// authorization cannot be initiated.
///
/// @see createPaymentMethod:options:
///
/// @param type The type of authorization to perform
- (void)createPaymentMethod:(BTPaymentProviderType)type;

/// Asynchronously create a payment method for the given payment type and options.
///
/// Use this method to alter the mechanisms used to create a payment method.
///
/// @see createPaymentMethod:
///
/// @param type    The type of authorization to perform
/// @param options Authorization options
- (void)createPaymentMethod:(BTPaymentProviderType)type options:(BTPaymentMethodCreationOptions)options;

/// Query whether it will be possible to create a payment method of the specified type.
///
/// @return YES if this payment provider could create a payment method of the specified type
- (BOOL)canCreatePaymentMethodWithProviderType:(BTPaymentProviderType)type;

/// Status of the last (or ongoing) payment method creation
@property (nonatomic, assign) BTPaymentProviderStatus status;

#if BT_ENABLE_APPLE_PAY

#pragma mark Payment Request Details

/// An array of PKPaymentSummaryItems
///
/// Currently only affects Apple Pay payments.
@property (nonatomic, strong) NSArray *paymentSummaryItems;

/// The set of required billing address fields (defaults to none)
///
/// Currently only affects Apple Pay payments.
@property (nonatomic, assign) PKAddressField requiredBillingAddressFields;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

/// The customer's billing address for pre-populating the checkout form
///
/// Currently only affects Apple Pay payments.
@property (nonatomic, assign) ABRecordRef billingAddress;

/// The customer's billing address for pre-populating the checkout form
///
/// Currently only affects Apple Pay payments.
@property (nonatomic, assign) ABRecordRef shippingAddress;

#pragma clang diagnostic pop

/// The billing contact for pre-populating the checkout form
///
/// Currently only affects Apple Pay payments.
@property (nonatomic, strong) PKContact *billingContact;

/// The shipping contact for pre-populating the checkout form
///
/// Currently only affects Apple Pay payments.
@property (nonatomic, strong) PKContact *shippingContact;

/// The set of required billing address fields (defaults to none)
///
/// Currently only affects Apple Pay payments.
@property (nonatomic, assign) PKAddressField requiredShippingAddressFields;

/// Available shipping methods
///
/// Currently only affects Apple Pay payments.
@property (nonatomic, copy) NSArray *shippingMethods;

/// Supported payment networks
///
/// Currently only affects Apple Pay payments.
@property (nonatomic, copy) NSArray *supportedNetworks;

#endif

@end
