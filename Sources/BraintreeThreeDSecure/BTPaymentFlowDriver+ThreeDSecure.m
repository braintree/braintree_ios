#import "BTPaymentFlowDriver+ThreeDSecure_Internal.h"
#import "BTThreeDSecureResult_Internal.h"
#import "BTThreeDSecureRequest_Internal.h"
#import "BTThreeDSecurePostalAddress_Internal.h"
#import "BTThreeDSecureAdditionalInformation_Internal.h"

#if __has_include(<Braintree/BraintreeThreeDSecure.h>) // CocoaPods
#import <Braintree/BTPaymentFlowDriver+ThreeDSecure.h>
#import <Braintree/BTThreeDSecureRequest.h>
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTPaymentFlowDriver_Internal.h>
#import <Braintree/BTAPIClient_Internal.h>
#import <Braintree/Braintree-Version.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreeThreeDSecure/BTPaymentFlowDriver+ThreeDSecure.h>
#import <BraintreeThreeDSecure/BTThreeDSecureRequest.h>
#import <BraintreeCore/BraintreeCore.h>
#import "../BraintreePaymentFlow/BTPaymentFlowDriver_Internal.h"
#import "../BraintreeCore/BTAPIClient_Internal.h"
#import "../BraintreeCore/Braintree-Version.h"

#else // Carthage
#import <BraintreeThreeDSecure/BTPaymentFlowDriver+ThreeDSecure.h>
#import <BraintreeThreeDSecure/BTThreeDSecureRequest.h>
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreePaymentFlow/BTPaymentFlowDriver_Internal.h>
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCore/Braintree-Version.h>

#endif

@implementation BTPaymentFlowDriver (ThreeDSecure)

NSString * const BTThreeDSecureFlowErrorDomain = @"com.braintreepayments.BTThreeDSecureFlowErrorDomain";
NSString * const BTThreeDSecureFlowInfoKey = @"com.braintreepayments.BTThreeDSecureFlowInfoKey";
NSString * const BTThreeDSecureFlowValidationErrorsKey = @"com.braintreepayments.BTThreeDSecureFlowValidationErrorsKey";

#pragma mark - ThreeDSecure Lookup

- (void)performThreeDSecureLookup:(BTThreeDSecureRequest *)request
                       completion:(void (^)(BTThreeDSecureResult  * _Nullable threeDSecureResult, NSError * _Nullable error))completionBlock {
    [self.apiClient fetchOrReturnRemoteConfiguration:^(__unused BTConfiguration *configuration, NSError *error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }

        NSMutableDictionary *customer = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *requestParameters = [@{ @"amount": request.amount,
                                                     @"customer": customer,
                                                     @"requestedThreeDSecureVersion": request.versionRequestedAsString } mutableCopy];
        if (request.dfReferenceID) {
            requestParameters[@"dfReferenceId"] = request.dfReferenceID;
        }

        if (request.accountTypeAsString) {
            requestParameters[@"accountType"] = request.accountTypeAsString;
        }

        if (request.challengeRequested) {
            requestParameters[@"challengeRequested"] = @(request.challengeRequested);
        }

        if (request.exemptionRequested) {
            requestParameters[@"exemptionRequested"] = @(request.exemptionRequested);
        }

        if (request.dataOnlyRequested) {
            requestParameters[@"dataOnlyRequested"] = @(request.dataOnlyRequested);
        }

        NSMutableDictionary *additionalInformation = [NSMutableDictionary dictionary];
        if (request.billingAddress) {
            [additionalInformation addEntriesFromDictionary:[request.billingAddress asParametersWithPrefix:@"billing"]];
        }

        if (request.mobilePhoneNumber) {
            additionalInformation[@"mobilePhoneNumber"] = request.mobilePhoneNumber;
        }

        if (request.email) {
            additionalInformation[@"email"] = request.email;
        }

        if (request.shippingMethodAsString) {
            additionalInformation[@"shippingMethod"] = request.shippingMethodAsString;
        }

        if (request.additionalInformation) {
            [additionalInformation addEntriesFromDictionary:[request.additionalInformation asParameters]];
        }

        if (additionalInformation.count) {
            requestParameters[@"additionalInfo"] = additionalInformation;
        }

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
                    if ([errorBody[@"threeDSecureInfo"] isObject]) {
                        userInfo[BTThreeDSecureFlowInfoKey] = [errorBody[@"threeDSecureInfo"] asDictionary];
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

            completionBlock([[BTThreeDSecureResult alloc] initWithJSON:body], nil);
        }];
    }];
}

- (void)prepareLookup:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *)request completion:(void (^)(NSString * _Nullable, NSError * _Nullable))completionBlock {
    BTThreeDSecureRequest *threeDSecureRequest = (BTThreeDSecureRequest *)request;
    NSError *integrationError;

    if (self.apiClient.clientToken == nil) {
        integrationError = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                               code:BTThreeDSecureFlowErrorTypeConfiguration
                                           userInfo:@{NSLocalizedDescriptionKey: @"A client token must be used for ThreeDSecure integrations."}];
    } else if (threeDSecureRequest.nonce == nil) {
        integrationError = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                               code:BTThreeDSecureFlowErrorTypeConfiguration
                                           userInfo:@{NSLocalizedDescriptionKey: @"BTThreeDSecureRequest nonce can not be nil."}];
    }

    if (integrationError != nil) {
        completionBlock(nil, integrationError);
        return;
    }

    [threeDSecureRequest prepareLookup:self.apiClient completion:^(NSError * _Nullable error) {
        if (error != nil) {
            completionBlock(nil, error);
        } else {
            NSMutableDictionary *requestParameters = [@{} mutableCopy];
            if (threeDSecureRequest.dfReferenceID) {
                requestParameters[@"dfReferenceId"] = threeDSecureRequest.dfReferenceID;
            }
            requestParameters[@"nonce"] = threeDSecureRequest.nonce;
            requestParameters[@"authorizationFingerprint"] = self.apiClient.clientToken.authorizationFingerprint;
            requestParameters[@"braintreeLibraryVersion"] = [NSString stringWithFormat:@"iOS-%@", BRAINTREE_VERSION];

            NSMutableDictionary *clientMetadata = [@{} mutableCopy];
            clientMetadata[@"sdkVersion"] = [NSString stringWithFormat:@"iOS/%@", BRAINTREE_VERSION];
            clientMetadata[@"requestedThreeDSecureVersion"] = @"2";
            requestParameters[@"clientMetadata"] = clientMetadata;

            NSError *jsonError;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestParameters options:0 error:&jsonError];

            if (!jsonData) {
                completionBlock(nil, jsonError);
            } else {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                completionBlock(jsonString, nil);
            }
        }
    }];
}

- (void)initializeChallengeWithLookupResponse:(NSString *)lookupResponse
                                      request:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *)request
                                   completion:(void (^)(BTPaymentFlowResult * _Nullable, NSError * _Nullable))completionBlock {
    [self setupPaymentFlow:request completion:completionBlock];

    BTJSON *jsonResponse = [[BTJSON alloc] initWithData:[lookupResponse dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
    BTThreeDSecureResult *lookupResult = [[BTThreeDSecureResult alloc] initWithJSON:jsonResponse];

    BTThreeDSecureRequest *threeDSecureRequest = (BTThreeDSecureRequest *)request;
    threeDSecureRequest.paymentFlowDriverDelegate = self;

    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable configurationError) {
        if (configurationError) {
            [threeDSecureRequest.paymentFlowDriverDelegate onPaymentComplete:nil error:configurationError];
            return;
        }
        [threeDSecureRequest processLookupResult:lookupResult configuration:configuration];
    }];
}

@end
