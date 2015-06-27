#import <Foundation/Foundation.h>

#pragma mark Braintree NSError Domain

/// Braintree NSError Domain
extern NSString *const BTBraintreeAPIErrorDomain;

#pragma mark Braintree NSError Codes

/// Error codes found in NSError objects returned in Braintree API.
typedef NS_ENUM(NSInteger, BTErrorCode) {
    /// An error occurred, but the exact cause was not determined.
    BTUnknownError = 0,
    /// A client error occurred for an undetermined reason.
    BTCustomerInputErrorUnknown,
    /// An error occurred due to invalid user input.
    BTCustomerInputErrorInvalid,
    /// An error occurred due to an authorization problem with SDK integration.
    BTMerchantIntegrationErrorUnauthorized,
    /// An error occurred due to a remove resource not found.
    BTMerchantIntegrationErrorNotFound,
    /// An error occurred due to a problem with the client token value.
    BTMerchantIntegrationErrorInvalidClientToken,
    /// The specified nonce was not found when querying information about it.
    BTMerchantIntegrationErrorNonceNotFound,
    /// A server-side error occurred. The result of your request is not specified. Please retry your request.
    BTServerErrorUnknown,
    /// A server-side error occurred due to the Gateway being unavailable. The result of your request is not specified. Please retry your request.
    BTServerErrorGatewayUnavailable,
    /// A server-side error occurred due to a network problem. See the underlying error for more details and retry your request.
    BTServerErrorNetworkUnavailable,
    /// An SSL error occurred.
    BTServerErrorSSL,
    /// A error occurred interpreting the server's response. Please retry your request.
    BTServerErrorUnexpectedError,
    /// The requested operation is not supported for this merchant or integration
    BTErrorUnsupported,
};

#pragma mark NSError userInfo Keys

/// NSError userInfo key for validation errors, present in errors with code BTCustomerInputErrorInvalid.
extern NSString *const BTCustomerInputBraintreeValidationErrorsKey;

/// NSError userInfo key for 3D Secure liability shift information, present in errors related to 3D Secure
extern NSString *BTThreeDSecureInfoKey;
