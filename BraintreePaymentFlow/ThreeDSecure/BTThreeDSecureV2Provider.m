#import "BTThreeDSecureV2Provider.h"
#import "BTConfiguration+ThreeDSecure.h"
#import "BTPaymentFlowDriver+ThreeDSecure_Internal.h"
#import "BTThreeDSecureAuthenticateJWT.h"
#if __has_include("BTAPIClient_Internal.h")
#import "BTAPIClient_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#endif
#import <CardinalMobile/CardinalMobile.h>

@interface BTThreeDSecureV2Provider() <CardinalValidationDelegate>

@property (strong, nonatomic) CardinalSession *cardinalSession;

@property (strong, nonatomic) BTThreeDSecureLookup *lookupResult;
@property (strong, nonatomic) BTAPIClient *apiClient;
@property (copy, nonatomic) BTThreeDSecureV2ProviderSuccessHandler successHandler;
@property (copy, nonatomic) BTThreeDSecureV2ProviderFailureHandler failureHandler;

@end

@implementation BTThreeDSecureV2Provider

+ (instancetype)initializeProviderWithConfiguration:(BTConfiguration *)configuration
                                          apiClient:(BTAPIClient *)apiClient
                                            request:(BTThreeDSecureRequest *)request
                                         completion:(BTThreeDSecureV2ProviderInitializeCompletionHandler)completionHandler {
    BTThreeDSecureV2Provider *instance = [self new];
    instance.apiClient = apiClient;
    instance.cardinalSession = [CardinalSession new];
    CardinalSessionConfiguration *cardinalConfiguration = [CardinalSessionConfiguration new];
    if (request.uiCustomization) {
        cardinalConfiguration.uiCustomization = request.uiCustomization;
    }
    CardinalSessionEnvironment cardinalEnvironment = CardinalSessionEnvironmentStaging;
    if ([[configuration.json[@"environment"] asString] isEqualToString:@"production"]) {
        cardinalEnvironment = CardinalSessionEnvironmentProduction;
    }
    cardinalConfiguration.deploymentEnvironment = cardinalEnvironment;
    [instance.cardinalSession configure:cardinalConfiguration];

    [instance.cardinalSession setupWithJWT:configuration.cardinalAuthenticationJWT
                               didComplete:^(__unused NSString * _Nonnull consumerSessionId) {
                                   [instance.apiClient sendAnalyticsEvent:@"ios.three-d-secure.cardinal-sdk.init.setup-completed"];
                                   completionHandler(@{@"dfReferenceId": consumerSessionId});
                               } didValidate:^(__unused CardinalResponse * _Nonnull validateResponse) {
                                   [instance.apiClient sendAnalyticsEvent:@"ios.three-d-secure.cardinal-sdk.init.setup-failed"];
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
                                didValidateDelegate:self];
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

- (void)cardinalSession:(__unused CardinalSession *)session stepUpDidValidateWithResponse:(CardinalResponse *)validateResponse serverJWT:(__unused NSString *)serverJWT {
    [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.verification-flow.cardinal-sdk.action-code.%@", [self analyticsStringForActionCode:validateResponse.actionCode]]];
    switch (validateResponse.actionCode) {
        case CardinalResponseActionCodeSuccess:
        case CardinalResponseActionCodeNoAction:
        case CardinalResponseActionCodeFailure: {
            [BTThreeDSecureAuthenticateJWT authenticateJWT:serverJWT
                                             withAPIClient:self.apiClient
                                           forLookupResult:self.lookupResult
                                                   success:self.successHandler
                                                   failure:self.failureHandler];
            break;
        }
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

- (NSString *)analyticsStringForActionCode:(CardinalResponseActionCode)actionCode {
    switch (actionCode) {
        case CardinalResponseActionCodeSuccess:
            return @"completed";
        case CardinalResponseActionCodeNoAction:
            return @"noaction";
        case CardinalResponseActionCodeFailure:
            return @"failure";
        case CardinalResponseActionCodeError:
            return @"failed";
        case CardinalResponseActionCodeCancel:
            return @"canceled";
    }
}

@end
