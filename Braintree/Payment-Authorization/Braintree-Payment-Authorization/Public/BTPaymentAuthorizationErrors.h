#pragma mark BTPaymentAuthorization Errors

/// BTPaymentAuthorization NSError Domain
extern NSString *const BTPaymentAuthorizationErrorDomain;

/// BTPaymentAuthorization NSError Codes
NS_ENUM(NSInteger, BTPaymentAuthorizationErrorCode) {
    BTPaymentAuthorizationErrorUnknown = 0,
    BTPaymentAuthorizationErrorOptionNotSupported,
    BTPaymentAuthorizationErrorInitialization,
};