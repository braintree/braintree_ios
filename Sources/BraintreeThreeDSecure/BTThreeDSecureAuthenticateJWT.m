#import "BTThreeDSecureAuthenticateJWT.h"
#import "BTPaymentFlowClient+ThreeDSecure_Internal.h"

// MARK: - Swift File Imports for Package Managers
#if __has_include(<Braintree/Braintree-Swift.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCore;
@import BraintreeCard;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else                                            // Carthage
#import <BraintreeCore/BraintreeCore-Swift.h>
#import <BraintreeCard/BraintreeCard-Swift.h>
#endif

// MARK: - Temporary Swift Module Imports
#if __has_include(<Braintree/BraintreeThreeDSecure.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>
#else                                            // SPM and Carthage
#import <BraintreeThreeDSecure/BraintreeThreeDSecure-Swift.h>
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
        if (failureHandler != nil) {
            failureHandler(error);
        }
        return;
    }

    NSString *urlSafeNonce = [lookupResult.tokenizedCard.nonce stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSDictionary *requestParameters = @{@"jwt": jwt, @"paymentMethodNonce": lookupResult.tokenizedCard.nonce};
    [apiClient POST:[NSString stringWithFormat:@"v1/payment_methods/%@/three_d_secure/authenticate_from_jwt", urlSafeNonce]
         parameters:requestParameters
         completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            if (error.code == BTCoreConstants.networkConnectionLostCode) {
                [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.network-connection.failure"];
            }
            [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.upgrade-payment-method.errored"];
            if (failureHandler != nil) {
                failureHandler(error);
            }
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

        if (successHandler != nil) {
            successHandler(result);
        }
    }];
}

@end
