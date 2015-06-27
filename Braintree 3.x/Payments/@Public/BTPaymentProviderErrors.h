#import <Foundation/Foundation.h>

#pragma mark Braintree-Payments Errors

/// BTPaymentAuthorization NSError Domain
extern NSString *const BTPaymentProviderErrorDomain;

/// BTPaymentAuthorization NSError Codes
typedef NS_ENUM(NSInteger, BTPaymentProviderErrorCode) {
    /// An unknown error related to creatingi a Braintree Payment Method
    BTPaymentProviderErrorUnknown = 0,

    /// An incompatible payment type and option was specified (e.g. Venmo via View Controller)
    BTPaymentProviderErrorOptionNotSupported,

    /// An error occured starting the user-facing payment method creation flow (e.g. App switch failed)
    BTPaymentProviderErrorInitialization,

    /// An error occured creating a Braintree Payment Method from the Apple Pay token
    BTPaymentProviderErrorPaymentMethodCreation,
};
