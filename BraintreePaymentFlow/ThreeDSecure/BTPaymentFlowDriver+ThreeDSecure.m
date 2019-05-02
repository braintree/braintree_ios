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
#import "BTThreeDSecurePostalAddress_Internal.h"
#import "BTThreeDSecureAdditionalInformation_Internal.h"

@implementation BTPaymentFlowDriver (ThreeDSecure)

NSString * const BTThreeDSecureFlowErrorDomain = @"com.braintreepayments.BTThreeDSecureFlowErrorDomain";
NSString * const BTThreeDSecureFlowInfoKey = @"com.braintreepayments.BTThreeDSecureFlowInfoKey";
NSString * const BTThreeDSecureFlowValidationErrorsKey = @"com.braintreepayments.BTThreeDSecureFlowValidationErrorsKey";

#pragma mark - ThreeDSecure Lookup

- (void)performThreeDSecureLookup:(BTThreeDSecureRequest *)request
                       completion:(void (^)(BTThreeDSecureLookup *threeDSecureResult, NSError *error))completionBlock {
    [self.apiClient fetchOrReturnRemoteConfiguration:^(__unused BTConfiguration *configuration, NSError *error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }

        NSMutableDictionary *customer = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *requestParameters = [@{ @"amount": request.amount, @"customer": customer } mutableCopy];
        if ([request getDfReferenceId]) {
            requestParameters[@"dfReferenceId"] = [request getDfReferenceId];
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

        if (request.shippingMethod) {
            additionalInformation[@"shippingMethod"] = request.shippingMethod;
        }

        if (request.additionalInformation) {
            [additionalInformation addEntriesFromDictionary:[request.additionalInformation asParameters]];
        }

        if (additionalInformation.count) {
            requestParameters[@"additionalInfo"] = additionalInformation;
        }

        if (request.challengeRequested) {
            requestParameters[@"challengeRequested"] = @(request.challengeRequested);
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
    }];
}

@end
