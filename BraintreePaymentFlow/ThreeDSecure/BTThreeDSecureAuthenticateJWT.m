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
    NSString *urlSafeNonce = [lookupResult.threeDSecureResult.tokenizedCard.nonce stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSDictionary *requestParameters = @{@"jwt": jwt, @"paymentMethodNonce": lookupResult.threeDSecureResult.tokenizedCard.nonce};
    [apiClient POST:[NSString stringWithFormat:@"v1/payment_methods/%@/three_d_secure/authenticate_from_jwt", urlSafeNonce]
         parameters:requestParameters
         completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
             BTThreeDSecureResult *result = [[BTThreeDSecureResult alloc] initWithJSON:body];
             if (result.errorMessage) {
                 NSError *error = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                      code:BTThreeDSecureFlowErrorTypeFailedAuthentication
                                                  userInfo:@{NSLocalizedDescriptionKey: result.errorMessage}];
                 failureHandler(error);
             } else {
                 successHandler(result);
             }
         }];
}

@end
