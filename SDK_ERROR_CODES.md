# Braintree iOS SDK Error Codes

See below for a comprehensive list of error types and codes thrown by each feature module:

* BraintreeAmericanExpress
    | Error Type | Error Code |
    |------------|------------|
    | BTAmericanExpressError.unknown | 0 |
    | BTAmericanExpressError.noRewardsData | 1 |
    | BTAmericanExpressError.deallocated | 2 |
* BraintreeApplePay
    | Error Type | Error Code |
    |------------|------------|
    | BTApplePayError.unknown | 0 |
    | BTApplePayError.unsupported | 1 |
    | BTApplePayError.noApplePayCardsReturned | 2 |
    | BTApplePayError.failedToCreateNonce | 3 |
* BraintreeCard
    | Error Type | Error Code |
    |------------|------------|
    | BTCardError.unknown | 0 |
    | BTCardError.integration | 1 |
    | BTCardError.customerInputInvalid | 2 |
    | BTCardError.cardAlreadyExists | 3 |
    | BTCardError.fetchConfigurationFailed | 4 |
* BraintreeCore
    | Error Type | Error Code |
    |------------|------------|
    | BTAPIClientError.configurationUnavailable | 0 |
    | BTAPIClientError.notAuthorized | 1 |
    | BTAPIClientError.deallocated | 2 |
    | BTClientTokenError.invalidAuthorizationFingerprint | 0 |
    | BTClientTokenError.invalidConfigURL | 1 |
    | BTClientTokenError.invalidFormat | 2 |
    | BTClientTokenError.unsupportedVersion | 3 |
    | BTClientTokenError.failedDecoding | 4 |
    | BTHTTPError.unknown | 0 |
    | BTHTTPError.responseContentTypeNotAcceptable | 1 |
    | BTHTTPError.clientError | 2 |
    | BTHTTPError.serverError | 3 |
    | BTHTTPError.missingBaseURL | 4 |
    | BTHTTPError.rateLimitError | 5 |
    | BTHTTPError.dataNotFound | 6 |
    | BTHTTPError.httpResponseInvalid | 7 |
    | BTHTTPError.urlStringInvalid | 8 |
    | BTHTTPError.clientApiURLInvalid | 9 |
    | BTHTTPError.invalidAuthorizationFingerprint | 10 |
    | BTHTTPError.serializationError | 11 |
    | BTHTTPError.deallocated | 12 |
    | BTJSONError.jsonSerializationFailure | 0 |
    | BTJSONError.indexInvalid | 1 |
    | BTJSONError.keyInvalid | 2 |
* BraintreeDataCollector
    | Error Type | Error Code |
    |------------|------------|
    | BTDataCollectorError.unknown | 0 |
    | BTDataCollectorError.jsonSerializationFailure | 1 |
    | BTDataCollectorError.encodingFailure | 2 |
* BraintreeLocalPayment
    | Error Type | Error Code |
    |------------|------------|
    | BTLocalPaymentError.unknown | 0 |
    | BTLocalPaymentError.disabled | 1 |
    | BTLocalPaymentError.appSwitchFailed | 2 |
    | BTLocalPaymentError.integration | 3 |
    | BTLocalPaymentError.noAccountData | 4 |
    | BTLocalPaymentError.canceled | 5 |
    | BTLocalPaymentError.failedToCreateNonce | 6 |
    | BTLocalPaymentError.fetchConfigurationFailed | 7 |
    | BTLocalPaymentError.missingRedirectURL | 8 |
    | BTLocalPaymentError.missingReturnURL | 9 |
    | BTLocalPaymentError.webSessionError | 10 |
* BraintreePayPal
    | Error Type | Error Code |
    |------------|------------|
    | BTPayPalError.disabled | 0 |
    | BTPayPalError.canceled | 1 |
    | BTPayPalError.fetchConfigurationFailed | 2 |
    | BTPayPalError.httpPostRequestError | 3 |
    | BTPayPalError.invalidURL | 4 |
    | BTPayPalError.asWebAuthenticationSessionURLInvalid | 5 |
    | BTPayPalError.invalidURLAction | 6 |
    | BTPayPalError.failedToCreateNonce | 7 |
    | BTPayPalError.webSessionError | 8 |
    | BTPayPalError.deallocated | 9 |
* BraintreePayPalNativeCheckout
    | Error Type | Error Code |
    |------------|------------|
    | BTPayPalNativeCheckoutError.invalidRequest | 0 |
    | BTPayPalNativeCheckoutError.fetchConfigurationFailed | 1 |
    | BTPayPalNativeCheckoutError.payPalNotEnabled | 2 |
    | BTPayPalNativeCheckoutError.payPalClientIDNotFound | 3 |
    | BTPayPalNativeCheckoutError.invalidEnvironment | 4 |
    | BTPayPalNativeCheckoutError.orderCreationFailed | 5 |
    | BTPayPalNativeCheckoutError.canceled | 6 |
    | BTPayPalNativeCheckoutError.checkoutSDKFailed | 7 |
    | BTPayPalNativeCheckoutError.tokenizationFailed | 8 |
    | BTPayPalNativeCheckoutError.parsingTokenizationResultFailed | 9 |
    | BTPayPalNativeCheckoutError.invalidJSONResponse | 10 |
    | BTPayPalNativeCheckoutError.deallocated | 11 |
* BraintreeSEPADirectDebit
    | Error Type | Error Code |
    |------------|------------|
    | BTSEPADirectDebitError.unknown | 0 |
    | BTSEPADirectDebitError.webFlowCanceled | 1 |
    | BTSEPADirectDebitError.resultURLInvalid | 2 |
    | BTSEPADirectDebitError.resultReturnedNil | 3 |
    | BTSEPADirectDebitError.approvalURLInvalid | 4 |
    | BTSEPADirectDebitError.authenticationResultNil | 5 |
    | BTSEPADirectDebitError.noBodyReturned | 6 |
    | BTSEPADirectDebitError.failedToCreateNonce | 7 |
    | BTSEPADirectDebitError.deallocated | 8 |
* BraintreeThreeDSecure
    | Error Type | Error Code |
    |------------|------------|
    | BTThreeDSecureError.unknown | 0 |
    | BTThreeDSecureError.failedLookup | 1 |
    | BTThreeDSecureError.failedAuthentication | 2 |
    | BTThreeDSecureError.configuration | 3 |
    | BTThreeDSecureError.noBodyReturned | 4 |
    | BTThreeDSecureError.canceled | 5 |
    | BTThreeDSecureError.invalidAPIClient | 6 |
    | BTThreeDSecureError.jsonSerializationFailure | 7 |
    | BTThreeDSecureError.deallocated | 8 |
* BraintreeVenmo
    | Error Type | Error Code |
    |------------|------------|
    | BTVenmoAppSwitchError.returnURLError | 0 |
    | BTVenmoError.unknown | 0 |
    | BTVenmoError.disabled | 1 |
    | BTVenmoError.appNotAvailable | 2 |
    | BTVenmoError.bundleDisplayNameMissing | 3 |
    | BTVenmoError.appSwitchFailed | 4 |
    | BTVenmoError.invalidReturnURL | 5 |
    | BTVenmoError.invalidBodyReturned | 6 |
    | BTVenmoError.invalidRedirectURL | 7 |
    | BTVenmoError.fetchConfigurationFailed | 8 |
    | BTVenmoError.enrichedCustomerDataDisabled | 9 |
    | BTVenmoError.canceled | 10 |