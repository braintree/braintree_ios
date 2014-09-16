#pragma mark Braintree-Payments Errors

/// BTPaymentAuthorization NSError Domain
extern NSString *const BTPaymentProviderErrorDomain;

/// BTPaymentAuthorization NSError Codes
NS_ENUM(NSInteger, BTPaymentProviderErrorCode) {
    BTPaymentProviderErrorUnknown = 0,
    BTPaymentProviderErrorOptionNotSupported,
    BTPaymentProviderErrorInitialization,
    /// An error occured creating a Braintree Payment Method from the Apple Pay token
    BTPaymentProviderErrorPaymentMethodCreation,
};