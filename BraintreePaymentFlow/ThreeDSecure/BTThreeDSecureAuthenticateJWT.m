#import "BTThreeDSecureAuthenticateJWT.h"
#import "BTPaymentFlowDriver+ThreeDSecure_Internal.h"
#if __has_include("BTAPIClient_Internal.h")
#import "BTAPIClient_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#endif

@implementation BTThreeDSecureAuthenticateJWT

+ (void)authenticateJWT:(NSString *)jwt
          withAPIClient:(BTAPIClient *)apiClient
        forLookupResult:(BTThreeDSecureLookup *)lookupResult
                success:(BTThreeDSecureV2ProviderSuccessHandler)successHandler
                failure:(BTThreeDSecureV2ProviderFailureHandler)failureHandler {
    [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.upgrade-payment-method.started"];

    if (! lookupResult.threeDSecureResult.tokenizedCard.nonce) {
        NSError *error = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                             code:BTThreeDSecureFlowErrorTypeFailedAuthentication
                                         userInfo:@{NSLocalizedDescriptionKey: @"Tokenized card nonce is required"}];
        [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.upgrade-payment-method.errored"];
        failureHandler(error);
        return;
    }

    NSString *urlSafeNonce = [lookupResult.threeDSecureResult.tokenizedCard.nonce stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSDictionary *requestParameters = @{@"jwt": jwt, @"paymentMethodNonce": lookupResult.threeDSecureResult.tokenizedCard.nonce};
    [apiClient POST:[NSString stringWithFormat:@"v1/payment_methods/%@/three_d_secure/authenticate_from_jwt", urlSafeNonce]
         parameters:requestParameters
         completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.upgrade-payment-method.errored"];
            failureHandler(error);
            return;
        }

        BTThreeDSecureResult *result = [[BTThreeDSecureResult alloc] initWithJSON:body];
        if (result.errorMessage) {
            // If we get an error message, return the BTThreeDSecureResult from the BTThreeDSecureLookup object
            // so that merchants can transact with the lookup nonce if desired.
            // Add the error message to object we're returning so that merchants know what went wrong.
            [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.upgrade-payment-method.failure.returned-lookup-nonce"];
            lookupResult.threeDSecureResult.tokenizedCard.threeDSecureInfo.errorMessage = result.errorMessage;
            successHandler(lookupResult.threeDSecureResult);
        } else {
            [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.upgrade-payment-method.succeeded"];
            successHandler(result);
        }
    }];
}

@end
