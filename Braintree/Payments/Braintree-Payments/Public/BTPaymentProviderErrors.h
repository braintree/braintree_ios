#pragma mark Braintree-Payments Errors

/// BTPaymentAuthorization NSError Domain
extern NSString *const BTPaymentProviderErrorDomain;

/// BTPaymentAuthorization NSError Codes
NS_ENUM(NSInteger, BTPaymentProviderErrorCode) {
    BTPaymentProviderErrorUnknown = 0,
    BTPaymentProviderErrorOptionNotSupported,
    BTPaymentProviderErrorInitialization,
};