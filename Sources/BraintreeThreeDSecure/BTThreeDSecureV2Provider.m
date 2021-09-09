#import "BTThreeDSecureV2Provider.h"
#import "BTPaymentFlowDriver+ThreeDSecure_Internal.h"
#import "BTThreeDSecureAuthenticateJWT.h"
#import "BTThreeDSecureV2UICustomization_Internal.h"
#import <CardinalMobile/CardinalMobile.h>

#if __has_include(<Braintree/BraintreeThreeDSecure.h>) // CocoaPods
#import <Braintree/BTConfiguration+ThreeDSecure.h>
#import <Braintree/BTThreeDSecureRequest.h>
#import <Braintree/BTThreeDSecureResult.h>
#import <Braintree/BTThreeDSecureLookup.h>
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTAPIClient_Internal.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreeThreeDSecure/BTConfiguration+ThreeDSecure.h>
#import <BraintreeThreeDSecure/BTThreeDSecureRequest.h>
#import <BraintreeThreeDSecure/BTThreeDSecureResult.h>
#import <BraintreeThreeDSecure/BTThreeDSecureLookup.h>
#import <BraintreeCore/BraintreeCore.h>
#import "../BraintreeCore/BTAPIClient_Internal.h"

#else // Carthage
#import <BraintreeThreeDSecure/BTConfiguration+ThreeDSecure.h>
#import <BraintreeThreeDSecure/BTThreeDSecureRequest.h>
#import <BraintreeThreeDSecure/BTThreeDSecureResult.h>
#import <BraintreeThreeDSecure/BTThreeDSecureLookup.h>
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCore/BTAPIClient_Internal.h>

#endif

@interface BTThreeDSecureV2Provider() <CardinalValidationDelegate>

@property (strong, nonatomic) CardinalSession *cardinalSession;

@property (strong, nonatomic) BTThreeDSecureResult *lookupResult;
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
    if (request.v2UICustomization) {
        cardinalConfiguration.uiCustomization = request.v2UICustomization.cardinalValue;
    }
    CardinalSessionEnvironment cardinalEnvironment = CardinalSessionEnvironmentStaging;
    if ([configuration.environment isEqualToString:@"production"]) {
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

- (void)processLookupResult:(BTThreeDSecureResult *)lookupResult
                    success:(BTThreeDSecureV2ProviderSuccessHandler)successHandler
                    failure:(BTThreeDSecureV2ProviderFailureHandler)failureHandler {
    self.lookupResult = lookupResult;
    self.successHandler = successHandler;
    self.failureHandler = failureHandler;
    [self.cardinalSession continueWithTransactionId:lookupResult.lookup.transactionID
                                            payload:lookupResult.lookup.PAReq
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
        case CardinalResponseActionCodeError:
        case CardinalResponseActionCodeTimeout: {
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
        case CardinalResponseActionCodeTimeout:
            return @"timeout";
    }
}

@end
