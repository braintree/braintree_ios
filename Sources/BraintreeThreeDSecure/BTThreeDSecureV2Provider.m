#import "BTThreeDSecureV2Provider.h"
#import "BTPaymentFlowDriver+ThreeDSecure_Internal.h"
#import "BTThreeDSecureAuthenticateJWT.h"
//#import <CardinalMobile/CardinalMobile.h>

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

typedef NS_ENUM(NSUInteger, BTProxyCardinalSessionEnvironment) {
    BTProxyCardinalSessionEnvironmentStaging,
    BTProxyCardinalSessionEnvironmentProduction
};

typedef NS_ENUM(NSUInteger, BTProxyCardinalResponseActionCode) {
    BTProxyCardinalResponseActionCodeSuccess,
    BTProxyCardinalResponseActionCodeNoAction,
    BTProxyCardinalResponseActionCodeFailure,
    BTProxyCardinalResponseActionCodeError,
    BTProxyCardinalResponseActionCodeCancel,
    BTProxyCardinalResponseActionCodeTimeout
};

@protocol BTProxyCardinalResponse <NSObject>
@property (nonatomic, readonly) BTProxyCardinalResponseActionCode actionCode;
@property (nonatomic, readonly) NSInteger errorNumber;
@property (nonatomic, readonly) NSString *errorDescription;
@end

@protocol BTProxyCardinalSessionConfiguration <NSObject>
@property (nonatomic, assign) BTProxyCardinalSessionEnvironment deploymentEnvironment;
@end

typedef void (^BTProxyCardinalSessionSetupDidCompleteHandler)(NSString *consumerSessionId);

typedef void (^BTProxyCardinalSessionSetupDidValidateHandler)(id<BTProxyCardinalResponse> validateResponse);

@protocol BTProxyCardinalSession <NSObject>

- (void)configure:(id<BTProxyCardinalSessionConfiguration>)sessionConfig;

- (void)setupWithJWT:(NSString*)jwtString
         didComplete:(BTProxyCardinalSessionSetupDidCompleteHandler)didCompleteHandler
         didValidate:(BTProxyCardinalSessionSetupDidValidateHandler)didValidateHandler;

- (void)continueWithTransactionId:(nonnull NSString *)transactionId
                          payload:(nonnull NSString *)payload
              didValidateDelegate:(nonnull id)validationDelegate;

@end

@protocol BTProxyCardinalValidationDelegate
- (void)cardinalSession:(id<BTProxyCardinalSession>)session
stepUpDidValidateWithResponse:(<BTProxyCardinalResponse>)validateResponse
              serverJWT:(NSString *)serverJWT;
@end

@interface BTThreeDSecureV2Provider() <BTProxyCardinalValidationDelegate>

@property (strong, nonatomic) id<BTProxyCardinalSession> cardinalSession;

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

    instance.cardinalSession = (id<BTProxyCardinalSession>)[NSClassFromString(@"CardinalSession") new];
    id<BTProxyCardinalSessionConfiguration> cardinalConfiguration = (id<BTProxyCardinalSessionConfiguration>)[NSClassFromString(@"CardinalSessionConfiguration") new];
//    if (request.uiCustomization) {
//        cardinalConfiguration.uiCustomization = request.uiCustomization;
//    }
    BTProxyCardinalSessionEnvironment cardinalEnvironment = BTProxyCardinalSessionEnvironmentStaging;
    if ([[configuration.json[@"environment"] asString] isEqualToString:@"production"]) {
        cardinalEnvironment = BTProxyCardinalSessionEnvironmentProduction;
    }
    cardinalConfiguration.deploymentEnvironment = cardinalEnvironment;
    [instance.cardinalSession configure:cardinalConfiguration];

    [instance.cardinalSession setupWithJWT:configuration.cardinalAuthenticationJWT
                               didComplete:^(__unused NSString * _Nonnull consumerSessionId) {
                                   [instance.apiClient sendAnalyticsEvent:@"ios.three-d-secure.cardinal-sdk.init.setup-completed"];
                                   completionHandler(@{@"dfReferenceId": consumerSessionId});
                               } didValidate:^(__unused id<BTProxyCardinalResponse> _Nonnull validateResponse) {
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
    [self.cardinalSession continueWithTransactionId:lookupResult.lookup.transactionId
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
- (void)cardinalSession:(__unused id<BTProxyCardinalSession>)session stepUpDidValidateWithResponse:(id<BTProxyCardinalResponse>)validateResponse serverJWT:(__unused NSString *)serverJWT {
    [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.verification-flow.cardinal-sdk.action-code.%@", [self analyticsStringForActionCode:validateResponse.actionCode]]];
    switch (validateResponse.actionCode) {
        case BTProxyCardinalResponseActionCodeSuccess:
        case BTProxyCardinalResponseActionCodeNoAction:
        case BTProxyCardinalResponseActionCodeFailure: {
            [BTThreeDSecureAuthenticateJWT authenticateJWT:serverJWT
                                             withAPIClient:self.apiClient
                                           forLookupResult:self.lookupResult
                                                   success:self.successHandler
                                                   failure:self.failureHandler];
            break;
        }
        case BTProxyCardinalResponseActionCodeError:
        case BTProxyCardinalResponseActionCodeTimeout: {
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
        case BTProxyCardinalResponseActionCodeCancel: {
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

- (NSString *)analyticsStringForActionCode:(BTProxyCardinalResponseActionCode)actionCode {
    switch (actionCode) {
        case BTProxyCardinalResponseActionCodeSuccess:
            return @"completed";
        case BTProxyCardinalResponseActionCodeNoAction:
            return @"noaction";
        case BTProxyCardinalResponseActionCodeFailure:
            return @"failure";
        case BTProxyCardinalResponseActionCodeError:
            return @"failed";
        case BTProxyCardinalResponseActionCodeCancel:
            return @"canceled";
        case BTProxyCardinalResponseActionCodeTimeout:
            return @"timeout";
    }
}

@end
