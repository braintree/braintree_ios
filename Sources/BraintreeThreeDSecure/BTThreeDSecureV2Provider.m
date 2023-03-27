#import "BTThreeDSecureV2Provider.h"
#import "BTPaymentFlowClient+ThreeDSecure_Internal.h"
#import "BTThreeDSecureAuthenticateJWT.h"
#import <CardinalMobile/CardinalMobile.h>

// MARK: - Objective-C File Imports for Package Managers
#if __has_include(<Braintree/BraintreeThreeDSecure.h>) // CocoaPods
#import <Braintree/BTThreeDSecureRequest.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreeThreeDSecure/BTThreeDSecureRequest.h>

#else // Carthage
#import <BraintreeThreeDSecure/BTThreeDSecureRequest.h>

#endif

// MARK: - Temporary Swift Module Imports
#if __has_include(<Braintree/BraintreeThreeDSecure.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>
#else                                            // SPM and Carthage
#import <BraintreeThreeDSecure/BraintreeThreeDSecure-Swift.h>
#endif

// MARK: - Swift File Imports for Package Managers
#if __has_include(<Braintree/Braintree-Swift.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCore;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else                                            // Carthage
#import <BraintreeCore/BraintreeCore-Swift.h>
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
                                            payload:lookupResult.lookup.paReq
                                didValidateDelegate:self];
}

- (void)callFailureHandlerWithErrorDomain:(NSErrorDomain)errorDomain
                                errorCode:(NSInteger)errorCode
                            errorUserInfo:(NSDictionary *)errorUserInfo
                           failureHandler:(BTThreeDSecureV2ProviderFailureHandler)failureHandler {
    NSError *error = [NSError errorWithDomain:errorDomain
                                         code:errorCode
                                     userInfo:errorUserInfo];

    if (failureHandler != nil) {
        failureHandler(error);
    }
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
            [self callFailureHandlerWithErrorDomain:BTPaymentFlowErrorDomain
                                          errorCode:BTPaymentFlowErrorTypeCanceled
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
