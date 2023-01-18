#import "BTCardClient_Internal.h"
#import "BTCardNonce_Internal.h"
#import "BTCard_Internal.h"

// MARK: - Objective-C File Imports for Package Managers
#if __has_include(<Braintree/BraintreeCard.h>) // CocoaPods
#import <Braintree/BTCardRequest.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreeCard/BTCardRequest.h>

#else // Carthage
#import <BraintreeCard/BTCardRequest.h>

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

NSString *const BTCardClientErrorDomain = @"com.braintreepayments.BTCardClientErrorDomain";
NSString *const BTCardClientGraphQLTokenizeFeature = @"tokenize_credit_cards";

@interface BTCardClient ()
@end

@implementation BTCardClient

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (!apiClient) {
        return nil;
    }
    if (self = [super init]) {
        self.apiClient = apiClient;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (void)tokenizeCard:(BTCard *)card completion:(void (^)(BTCardNonce *tokenizedCard, NSError *error))completion {
    BTCardRequest *request = [[BTCardRequest alloc] initWithCard:card];

    if (!self.apiClient) {
        NSError *error = [NSError errorWithDomain:BTCardClientErrorDomain
                                             code:BTCardClientErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTCardClient tokenization failed because BTAPIClient is nil."}];
        completion(nil, error);
        return;
    }

    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
            return;
        }

        if ([self isGraphQLEnabledForCardTokenization:configuration]) {
            
            if (request.card.authenticationInsightRequested && !request.card.merchantAccountID) {
                NSError *error = [NSError errorWithDomain:BTCardClientErrorDomain
                                                     code:BTCardClientErrorTypeIntegration
                                                 userInfo:@{NSLocalizedDescriptionKey: @"BTCardClient tokenization failed because a merchant account ID is required when authenticationInsightRequested is true."}];
                completion(nil, error);
                return;
            }
            
            NSDictionary *parameters = [request.card graphQLParameters];
            [self.apiClient POST:@""
                      parameters:parameters
                        httpType:BTAPIClientHTTPServiceGraphQLAPI
                      completion:^(BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, NSError * _Nullable error)
             {
                 if (error) {
                     if (error.code == BTCoreConstants.networkConnectionLostCode) {
                         [self.apiClient sendAnalyticsEvent:@"ios.tokenize-card.graphQL.network-connection.failure"];
                     }
                     NSHTTPURLResponse *response = error.userInfo[BTHTTPError.urlResponseKey];
                     NSError *callbackError = error;

                     if (response.statusCode == 422) {
                         if (error.userInfo) {
                             callbackError = [self constructCallbackErrorForErrorUserInfo:error.userInfo error:error];
                         }
                     }

                     [self sendGraphQLAnalyticsEventWithSuccess:NO];

                     completion(nil, callbackError);
                     return;
                 }

                 BTJSON *cardJSON = body[@"data"][@"tokenizeCreditCard"];
                 [self sendGraphQLAnalyticsEventWithSuccess:YES];

                 BTCardNonce *cardNonce = [BTCardNonce cardNonceWithGraphQLJSON:cardJSON];
                 completion(cardNonce, cardJSON.asError);
             }];
        } else {
            NSDictionary *parameters = [self clientAPIParametersForCard:request];
            [self.apiClient POST:@"v1/payment_methods/credit_cards"
                      parameters:parameters
                      completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error)
             {
                 if (error != nil) {
                     if (error.code == BTCoreConstants.networkConnectionLostCode) {
                         [self.apiClient sendAnalyticsEvent:@"ios.tokenize-card.network-connection.failure"];
                     }
                     NSHTTPURLResponse *response = error.userInfo[BTHTTPError.urlResponseKey];
                     NSError *callbackError = error;

                     if (response.statusCode == 422) {
                         if (error.userInfo) {
                             callbackError = [self constructCallbackErrorForErrorUserInfo:error.userInfo error:error];
                         }
                     }
                     
                     [self sendAnalyticsEventWithSuccess:NO];

                     completion(nil, callbackError);
                     return;
                 }

                 BTJSON *cardJSON = body[@"creditCards"][0];
                
                 [self sendAnalyticsEventWithSuccess:!cardJSON.isError];

                 // cardNonceWithJSON returns nil when cardJSON is nil, cardJSON.asError is nil when cardJSON is non-nil
                 BTCardNonce *cardNonce = [BTCardNonce cardNonceWithJSON:cardJSON];
                 completion(cardNonce, cardJSON.asError);
             }];
        }
    }];
}

#pragma mark - Analytics

- (void)sendAnalyticsEventWithSuccess:(BOOL)success {
    NSString *event = [NSString stringWithFormat:@"ios.%@.card.%@", self.apiClient.metadata.integrationString, success ? @"succeeded" : @"failed"];
    [self.apiClient sendAnalyticsEvent:event];
}

- (void)sendGraphQLAnalyticsEventWithSuccess:(BOOL)success {
    NSString *event = [NSString stringWithFormat:@"ios.card.graphql.tokenization.%@", success ? @"success" : @"failure"];
    [self.apiClient sendAnalyticsEvent:event];
}

#pragma mark - Helpers

+ (NSDictionary *)validationErrorUserInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *mutableUserInfo = [userInfo mutableCopy];
    BTJSON *jsonResponse = userInfo[BTHTTPError.jsonResponseBodyKey];
    if ([jsonResponse asDictionary]) {
        mutableUserInfo[@"BTCustomerInputBraintreeValidationErrorsKey"] = [jsonResponse asDictionary];

        NSString *errorMessage = [jsonResponse[@"error"][@"message"] asString];
        if (errorMessage) {
            mutableUserInfo[NSLocalizedDescriptionKey] = errorMessage;
        }

        BTJSON *fieldError = [jsonResponse[@"fieldErrors"] asArray].firstObject;
        BTJSON *firstFieldError = [fieldError[@"fieldErrors"] asArray].firstObject;
        NSString *firstFieldErrorMessage = [firstFieldError[@"message"] asString];
        if (firstFieldErrorMessage) {
            mutableUserInfo[NSLocalizedFailureReasonErrorKey] = firstFieldErrorMessage;
        }
    }
    return [mutableUserInfo copy];
}

- (NSDictionary *)clientAPIParametersForCard:(BTCardRequest *)request {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (request.card.parameters) {
        parameters[@"credit_card"] = [request.card.parameters copy];
    }
    parameters[@"_meta"] = @{
                             @"source" : self.apiClient.metadata.sourceString,
                             @"integration" : self.apiClient.metadata.integrationString,
                             @"sessionId" : self.apiClient.metadata.sessionID,
                             };
    
    if (request.card.authenticationInsightRequested) {
        parameters[@"authenticationInsight"] = @YES;
        parameters[@"merchantAccountId"] = request.card.merchantAccountID;
    }

    return [parameters copy];
}

- (BOOL)isGraphQLEnabledForCardTokenization:(BTConfiguration *)configuration {
    NSArray *graphQLFeatures = [configuration.json[@"graphQL"][@"features"] asStringArray];

    return graphQLFeatures && [graphQLFeatures containsObject:BTCardClientGraphQLTokenizeFeature];
}

- (NSError *)constructCallbackErrorForErrorUserInfo:(NSDictionary *)errorUserInfo error:(NSError *)error {
    NSError *callbackError = error;
    BTJSON *errorCode = nil;
    
    BTJSON *errorResponse = [error.userInfo objectForKey:BTHTTPError.jsonResponseBodyKey];
    BTJSON *fieldErrors = [errorResponse[@"fieldErrors"] asArray].firstObject;
    errorCode = [fieldErrors[@"fieldErrors"] asArray].firstObject[@"code"];

    if (errorCode == nil) {
        BTJSON *errorResponse = [errorUserInfo objectForKey:BTHTTPError.jsonResponseBodyKey];
        errorCode = [errorResponse[@"errors"] asArray].firstObject[@"extensions"][@"legacyCode"];
    }

    // Gateway error code for card already exists
    if ([errorCode.asString  isEqual: @"81724"]) {
        callbackError = [NSError errorWithDomain:BTCardClientErrorDomain
                                            code:BTCardClientErrorTypeCardAlreadyExists
                                        userInfo:[self.class validationErrorUserInfo:error.userInfo]];
    } else {
        callbackError = [NSError errorWithDomain:BTCardClientErrorDomain
                                            code:BTCardClientErrorTypeCustomerInputInvalid
                                        userInfo:[self.class validationErrorUserInfo:error.userInfo]];
    }
    return callbackError;
}

@end
