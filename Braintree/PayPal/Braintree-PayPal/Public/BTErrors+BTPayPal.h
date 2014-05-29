#import "BTErrors.h"

/// Braintree+PayPal NSError Domain
extern NSString *const BTBraintreePayPalErrorDomain;

/// Errors codes
NS_ENUM(NSInteger, BTPayPalErrorCode) {
    BTMerchantIntegrationErrorPayPalConfiguration = 1,
};