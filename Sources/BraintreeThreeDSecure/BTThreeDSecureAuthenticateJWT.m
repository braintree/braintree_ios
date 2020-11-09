#import "BTThreeDSecureAuthenticateJWT.h"
#import "BTPaymentFlowDriver+ThreeDSecure_Internal.h"
#import "BTThreeDSecureResult_Internal.h"

#if __has_include(<Braintree/BraintreeThreeDSecure.h>) // CocoaPods
#import <Braintree/BraintreeCard.h>
#import <Braintree/BTAPIClient_Internal.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreeCard/BraintreeCard.h>
#import "../BraintreeCore/BTAPIClient_Internal.h"

#else // Carthage
#import <BraintreeCard/BraintreeCard.h>
#import <BraintreeCore/BTAPIClient_Internal.h>

#endif

@implementation BTThreeDSecureAuthenticateJWT

+ (void)authenticateJWT:(NSString *)jwt
          withAPIClient:(BTAPIClient *)apiClient
        forLookupResult:(BTThreeDSecureResult *)lookupResult
                success:(BTThreeDSecureV2ProviderSuccessHandler)successHandler
                failure:(BTThreeDSecureV2ProviderFailureHandler)failureHandler {
    [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.upgrade-payment-method.started"];

    if (!lookupResult.tokenizedCard.nonce) {
        NSError *error = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                             code:BTThreeDSecureFlowErrorTypeFailedAuthentication
                                         userInfo:@{NSLocalizedDescriptionKey: @"Tokenized card nonce is required"}];
        [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.upgrade-payment-method.errored"];
        failureHandler(error);
        return;
    }

    NSString *urlSafeNonce = [lookupResult.tokenizedCard.nonce stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSDictionary *requestParameters = @{@"jwt": jwt, @"paymentMethodNonce": lookupResult.tokenizedCard.nonce};
    [apiClient POST:[NSString stringWithFormat:@"v1/payment_methods/%@/three_d_secure/authenticate_from_jwt", urlSafeNonce]
         parameters:requestParameters
         completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.upgrade-payment-method.errored"];
            failureHandler(error);
            return;
        }

        BTThreeDSecureResult *result = [[BTThreeDSecureResult alloc] initWithJSON:body];
        if (result.tokenizedCard && !result.errorMessage) {
            [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.upgrade-payment-method.succeeded"];
        } else {
            [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.upgrade-payment-method.failure.returned-lookup-nonce"];

            // If authentication wasn't successful, add the BTCardNonce from the lookup result to the authentication result
            // so that merchants can transact with the lookup nonce if desired.
            result.tokenizedCard = lookupResult.tokenizedCard;
        }

        successHandler(result);
    }];
}

@end
