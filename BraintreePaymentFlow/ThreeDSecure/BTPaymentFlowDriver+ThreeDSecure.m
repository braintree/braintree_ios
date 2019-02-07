#import "BTPaymentFlowDriver+ThreeDSecure.h"
#if __has_include("BTAPIClient_Internal.h")
#import "BTAPIClient_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#endif
#import "BTPaymentFlowDriver_Internal.h"
#import "BTPaymentFlowDriver+ThreeDSecure_Internal.h"
#import "BTThreeDSecureResult.h"
#import "BTThreeDSecureRequest.h"
#import "BTThreeDSecureRequest_Internal.h"
#import "BTConfiguration+ThreeDSecure.h"
#import <CardinalMobile/CardinalMobile.h>

@implementation BTPaymentFlowDriver (ThreeDSecure)

NSString * const BTThreeDSecureFlowErrorDomain = @"com.braintreepayments.BTThreeDSecureFlowErrorDomain";
NSString * const BTThreeDSecureFlowInfoKey = @"com.braintreepayments.BTThreeDSecureFlowInfoKey";
NSString * const BTThreeDSecureFlowValidationErrorsKey = @"com.braintreepayments.BTThreeDSecureFlowValidationErrorsKey";

#pragma mark - ThreeDSecure Lookup

- (void)performThreeDSecureLookup:(BTThreeDSecureRequest *)request
                       completion:(void (^)(BTThreeDSecureLookup *threeDSecureResult, NSError *error))completionBlock
{
    CardinalSession *cardinalSession = [self createCardinalSession];
    
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }
        
        [cardinalSession setupWithJWT:configuration.cardinalAuthenticationJWT
                          didComplete:^(NSString * _Nonnull consumerSessionId) {
                              NSMutableDictionary *requestParameters = [[request asParameters] mutableCopy];
                              requestParameters[@"df_reference_id"] = consumerSessionId;
                              
                              NSString *urlSafeNonce = [request.nonce stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                              [self.apiClient POST:[NSString stringWithFormat:@"v1/payment_methods/%@/three_d_secure/lookup", urlSafeNonce]
                                        parameters:requestParameters
                                        completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
                                            
                                            if (error) {
                                                // Provide more context for card validation error when status code 422
                                                if ([error.domain isEqualToString:BTHTTPErrorDomain] &&
                                                    error.code == BTHTTPErrorCodeClientError &&
                                                    ((NSHTTPURLResponse *)error.userInfo[BTHTTPURLResponseKey]).statusCode == 422) {
                                                    
                                                    NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                                                    BTJSON *errorBody = error.userInfo[BTHTTPJSONResponseBodyKey];
                                                    
                                                    if ([errorBody[@"error"][@"message"] isString]) {
                                                        userInfo[NSLocalizedDescriptionKey] = [errorBody[@"error"][@"message"] asString];
                                                    }
                                                    if ([errorBody[@"threeDSecureFlowInfo"] isObject]) {
                                                        userInfo[BTThreeDSecureFlowInfoKey] = [errorBody[@"threeDSecureFlowInfo"] asDictionary];
                                                    }
                                                    if ([errorBody[@"error"] isObject]) {
                                                        userInfo[BTThreeDSecureFlowValidationErrorsKey] = [errorBody[@"error"] asDictionary];
                                                    }
                                                    
                                                    error = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                                                code:BTThreeDSecureFlowErrorTypeFailedLookup
                                                                            userInfo:userInfo];
                                                }
                                                
                                                completionBlock(nil, error);
                                                return;
                                            }
                                            
                                            BTJSON *lookupJSON = body[@"lookup"];

                                            BTThreeDSecureLookup *lookup = [[BTThreeDSecureLookup alloc] initWithJSON:lookupJSON];
                                            lookup.threeDSecureResult = [[BTThreeDSecureResult alloc] initWithJSON:body];
                                            
                                            completionBlock(lookup, nil);
                                        }];
                          } didValidate:^(CardinalResponse * _Nonnull validateResponse) {
                              //error fallback?
                              NSLog(@"%@", validateResponse);
                              // TODO Handle cases
                          }];
    }];
}

- (CardinalSession *)createCardinalSession {
    CardinalSession *cardinalSession = [CardinalSession new];
    cardinalSession.stepUpDelegate = self;
    CardinalSessionConfig *config = [CardinalSessionConfig new];
    config.deploymentEnvironment = CardinalSessionEnvironmentStaging;
    config.timeout = CardinalSessionTimeoutStandard;
    config.uiType = CardinalSessionUITypeBoth;
    
    config.enableQuickAuth = false;
    [cardinalSession configure:config];
    
    return cardinalSession;
}

#pragma mark - Cardinal Delegate

- (void)cardinalSession:(__unused CardinalSession *)session
stepUpDataDidBecomeReady:(CardinalStepUpData *)stepUpData {
    NSLog(@"%@", stepUpData);
}

- (void)cardinalSession:(__unused CardinalSession *)session
    stepUpDataDidUpdate:(CardinalStepUpData *)stepUpData {
    NSLog(@"%@", stepUpData);
}

-(void)cardinalSession:(__unused CardinalSession *)session stepUpDidValidateWithResponse:(CardinalResponse *)validateResponse serverJWT:(__unused NSString *)serverJWT{
    switch (validateResponse.actionCode) {
        case CardinalResponseActionCodeSuccess:
            // Handle successful transaction, send JWT to backend to verify
            break;
            
        case CardinalResponseActionCodeNoAction:
            // Handle no actionable outcome
            break;
            
        case CardinalResponseActionCodeFailure:
            // Handle failed transaction attempt
            break;
            
        case CardinalResponseActionCodeError:
            // Handle service level error
            break;
        default:
            
            break;
            //        case CardinalResponseActionCodeCancel:
            //            // Handle transaction canceled by user
            //            break
            //
            //        case CardinalResponseActionCodeUnknown:
            //            // Handle unknown error
            //            break;
    }
}

@end

