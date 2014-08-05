#import <Foundation/Foundation.h>

#pragma mark Braintree NSError Domain

/// Braintree NSError Domain
extern NSString *const BTBraintreeAPIErrorDomain;

#pragma mark Braintree NSError Codes

/// Error codes found in NSError objects returned in Braintree API.
NS_ENUM(NSInteger, BTErrorCode) {
    /// An error occurred, but the exact cause was not determined.
    BTUnknownError = 0,
    /// A client error occurred for an undetermined reason.
    BTCustomerInputErrorUnknown,
    /// An error occurred due to invalid user input.
    BTCustomerInputErrorInvalid,
    /// An error occured due to an authorization problem with SDK integration.
    BTMerchantIntegrationErrorUnauthorized,
    /// An error occured due to a remove resource not found.
    BTMerchantIntegrationErrorNotFound,
    /// An error occured due to a problem with the client token value.
    BTMerchantIntegrationErrorInvalidClientToken,
    /// The specified nonce was not found when querying information about it.
    BTMerchantIntegrationErrorNonceNotFound,
    /// A server-side error occured. The result of your request is not specified. Please retry your request.
    BTServerErrorUnknown,
    /// A server-side error occured due to the Gateway being unavailable. The result of your reuqest is not specified. Please retry your request.
    BTServerErrorGatewayUnavailable,
    /// A server-side error occured due to a network problem. See the underlying error for more details and retry your request.
    BTServerErrorNetworkUnavailable,
    /// An SSL error occured.
    BTServerErrorSSL,
    /// A error occured interpreting the server's response. Please retry your request.
    BTServerErrorUnexpectedError,
};

#pragma mark NSError userInfo Keys

/// NSError userInfo key for validation errors, present in errors with code BTCustomerInputErrorInvalid.
extern NSString *const BTCustomerInputBraintreeValidationErrorsKey;
