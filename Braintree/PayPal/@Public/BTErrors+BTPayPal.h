#import "BTErrors.h"

/// Braintree+PayPal NSError Domain
extern NSString *const BTBraintreePayPalErrorDomain;

/// Errors codes
typedef NS_ENUM(NSInteger, BTPayPalErrorCode) {
    BTPayPalUnknownError = 0,
    BTMerchantIntegrationErrorPayPalConfiguration = 1,

    /// PayPal is disabled
    BTPayPalErrorPayPalDisabled = 2,


};
