#import "BTErrors.h"

/// Braintree+PayPal NSError Domain
extern NSString *const BTBraintreePayPalErrorDomain;

/// Errors codes
NS_ENUM(NSInteger, BTPayPalErrorCode) {
    BTPayPalUnknownError = 0,
    BTMerchantIntegrationErrorPayPalConfiguration = 1,

    /// PayPal is disabled
    BTPayPalErrorPayPalDisabled = 2,

    /// PayPal app switch is disabled.
    ///
    /// This flag is set via the client token and can be configured in the Braintree control panel.
    /// It can also be overridden in certain cases (see BTPaymentProviderType.)
    BTPayPalErrorAppSwitchDisabled = 3,

    /// The return URL scheme is nil or invalid.
    BTPayPalErrorAppSwitchReturnURLScheme = 4,

    /// A compatible version of the PayPal app is not available on this device,
    BTPayPalErrorAppSwitchUnavailable = 5,

    /// Failed to switch to PayPal when attempting to initiate app switch payment method creation.
    BTPayPalErrorAppSwitchFailed = 6,

    /// Parameters used to initiate app switch are invalid
    BTPayPalErrorAppSwitchInvalidParameters = 7,
};