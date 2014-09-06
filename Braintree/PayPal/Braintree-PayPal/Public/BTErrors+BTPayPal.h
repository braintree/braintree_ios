#import "BTErrors.h"

/// Braintree+PayPal NSError Domain
extern NSString *const BTBraintreePayPalErrorDomain;

/// Errors codes
NS_ENUM(NSInteger, BTPayPalErrorCode) {
    BTPayPalUnknownError = 0,
    BTMerchantIntegrationErrorPayPalConfiguration = 1,

    /// PayPal app switch is not enabled.
    ///
    /// This flag is set via the client token and can be configured in the Braintree control panel.
    /// It can also be overridden in certain cases (see BTPaymentProviderType.)
    BTPayPalErrorAppSwitchDisabled = 2,

    /// A compatible version of the PayPal app is not available on this device.
    BTPayPalErrorAppSwitchPayPalAppNotAvailable = 3,

    /// Failed to switch to PayPal when attempting to initiate app switch payment method creation.
    BTPayPalErrorAppSwitchFailed = 4,
};