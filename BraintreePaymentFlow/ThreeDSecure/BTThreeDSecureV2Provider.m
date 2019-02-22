#import "BTThreeDSecureV2Provider.h"
#import "BTConfiguration+ThreeDSecure.m"
#import "BTPaymentFlowDriver+ThreeDSecure_Internal.h"
#import <CardinalMobile/CardinalMobile.h>

@interface BTThreeDSecureV2Provider() <CardinalValidationDelegate>

@property (strong, nonatomic) BTAPIClient *apiClient;
@property (strong, nonatomic) CardinalSession *cardinalSession;

@property (strong, nonatomic) BTThreeDSecureLookup *lookupResult;
@property (copy, nonatomic) BTThreeDSecureV2ProviderSuccessHandler successHandler;
@property (copy, nonatomic) BTThreeDSecureV2ProviderFailureHandler failureHandler;

@end

@implementation BTThreeDSecureV2Provider

+ (instancetype)initializeProviderWithApiClient:(BTAPIClient *)apiClient
                                  configuration:(BTConfiguration *)configuration
                                     completion:(BTThreeDSecureV2ProviderInitializeCompletionHandler)completionHandler {
    BTThreeDSecureV2Provider *instance = [self new];
    instance.apiClient = apiClient;
    instance.cardinalSession = [CardinalSession new];
    // TODO: Switch between staging and production
    CardinalSessionConfig *cardinalConfiguration = [CardinalSessionConfig new];
    cardinalConfiguration.deploymentEnvironment = CardinalSessionEnvironmentStaging;
    [instance.cardinalSession configure:cardinalConfiguration];

    [instance.cardinalSession setupWithJWT:configuration.cardinalAuthenticationJWT
                               didComplete:^(__unused NSString * _Nonnull consumerSessionId) {
                                   completionHandler(@{@"dfReferenceId": consumerSessionId});
                               } didValidate:^(__unused CardinalResponse * _Nonnull validateResponse) {
                                   // TODO: continue lookup and assume it will be v1?
                                   completionHandler(@{});
                               }];

    return instance;
}

- (void)processLookupResult:(BTThreeDSecureLookup *)lookupResult
                    success:(BTThreeDSecureV2ProviderSuccessHandler)successHandler
                    failure:(BTThreeDSecureV2ProviderFailureHandler)failureHandler {
    self.lookupResult = lookupResult;
    self.successHandler = successHandler;
    self.failureHandler = failureHandler;
    [self.cardinalSession continueWithTransactionId:lookupResult.transactionId
                                            payload:lookupResult.PAReq
                                             acsUrl:[lookupResult.acsURL absoluteString]
                                  directoryServerID:CCADirectoryServerIDEMVCo1
                                didValidateDelegate:self];
}

- (void)authenticateCardinalJWT:(NSString *)cardinalJWT
                      forLookup:(BTThreeDSecureLookup *)lookupResult
                        success:(BTThreeDSecureV2ProviderSuccessHandler)successHandler
                        failure:(BTThreeDSecureV2ProviderFailureHandler)failureHandler {
    NSString *urlSafeNonce = [lookupResult.threeDSecureResult.tokenizedCard.nonce stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSDictionary *requestParameters = @{@"jwt": cardinalJWT, @"paymentMethodNonce": lookupResult.threeDSecureResult.tokenizedCard.nonce};
    [self.apiClient POST:[NSString stringWithFormat:@"v1/payment_methods/%@/three_d_secure/authenticate_from_jwt", urlSafeNonce]
              parameters:requestParameters
              completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
                  BTThreeDSecureResult *result = [[BTThreeDSecureResult alloc] initWithJSON:body];
                  if (result.errorMessage) {
                      [self callFailureHandlerWithErrorDomain:BTThreeDSecureFlowErrorDomain
                                                    errorCode:BTThreeDSecureFlowErrorTypeFailedAuthentication
                                                errorUserInfo:@{NSLocalizedDescriptionKey: result.errorMessage}
                                               failureHandler:failureHandler];
                  } else {
                      successHandler(result);
                  }
              }];
}

- (void)callFailureHandlerWithErrorDomain:(NSErrorDomain)errorDomain
                                errorCode:(NSInteger)errorCode
                            errorUserInfo:(NSDictionary *)errorUserInfo
                           failureHandler:(BTThreeDSecureV2ProviderFailureHandler)failureHandler {
    NSError *error = [NSError errorWithDomain:errorDomain
                                         code:errorCode
                                     userInfo:errorUserInfo];

    failureHandler(error);
}

#pragma mark - Cardinal Delegate

- (void)cardinalSession:(__unused CardinalSession *)session stepUpDidValidateWithResponse:(CardinalResponse *)validateResponse serverJWT:(__unused NSString *)serverJWT{
    switch (validateResponse.actionCode) {
        case CardinalResponseActionCodeSuccess:
        case CardinalResponseActionCodeNoAction:
        case CardinalResponseActionCodeFailure: {
            [self authenticateCardinalJWT:serverJWT
                                forLookup:self.lookupResult
                                  success:self.successHandler
                                  failure:self.failureHandler];
            break;
        }
        case CardinalResponseActionCodeUnknown:
        case CardinalResponseActionCodeError: {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
            if (validateResponse.errorDescription) {
                userInfo[NSLocalizedDescriptionKey] = validateResponse.errorDescription;
            }

            BTThreeDSecureFlowErrorType errorCode = BTThreeDSecureFlowErrorTypeUnknown;
            if (validateResponse.errorNumber == 1050) {
                errorCode = BTThreeDSecureFlowErrorTypeFailedAuthentication;
            }

            [self callFailureHandlerWithErrorDomain:BTThreeDSecureFlowErrorDomain
                                          errorCode:errorCode
                                      errorUserInfo:userInfo
                                     failureHandler:self.failureHandler];
            break;
        }
        case CardinalResponseActionCodeCancel: {
            [self callFailureHandlerWithErrorDomain:BTPaymentFlowDriverErrorDomain
                                          errorCode:BTPaymentFlowDriverErrorTypeCanceled
                                      errorUserInfo:nil
                                     failureHandler:self.failureHandler];
            break;
        }
    }

    self.lookupResult = nil;
    self.successHandler = nil;
    self.failureHandler = nil;
}

@end
