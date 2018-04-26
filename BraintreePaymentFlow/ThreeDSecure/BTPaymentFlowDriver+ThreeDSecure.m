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
#import "BTThreeDSecurePostalAddress_Internal.h"

@implementation BTPaymentFlowDriver (ThreeDSecure)

NSString * const BTThreeDSecureFlowErrorDomain = @"com.braintreepayments.BTThreeDSecureFlowErrorDomain";
NSString * const BTThreeDSecureFlowInfoKey = @"com.braintreepayments.BTThreeDSecureFlowInfoKey";
NSString * const BTThreeDSecureFlowValidationErrorsKey = @"com.braintreepayments.BTThreeDSecureFlowValidationErrorsKey";

#pragma mark - ThreeDSecure Lookup

- (void)performThreeDSecureLookup:(BTThreeDSecureRequest *)request
                       completion:(void (^)(BTThreeDSecureLookup *threeDSecureResult, NSError *error))completionBlock
{
    [self.apiClient fetchOrReturnRemoteConfiguration:^(__unused BTConfiguration *configuration, NSError *error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }
        
        NSMutableDictionary *customer = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *requestParameters = [@{ @"amount": request.amount, @"customer": customer } mutableCopy];

        if (request.billingAddress) {
            customer[@"billingAddress"] = [request.billingAddress asParameters];
        }
        
        if (request.mobilePhoneNumber) {
            customer[@"mobilePhoneNumber"] = request.mobilePhoneNumber;
        }
        
        if (request.email) {
            customer[@"email"] = request.email;
        }
        
        if (request.shippingMethod) {
            customer[@"shippingMethod"] = request.shippingMethod;
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
                      
                      BTThreeDSecureLookup *lookup = [[BTThreeDSecureLookup alloc] init];
                      lookup.acsURL = [lookupJSON[@"acsUrl"] asURL];
                      lookup.PAReq = [lookupJSON[@"pareq"] asString];
                      lookup.MD = [lookupJSON[@"md"] asString];
                      lookup.termURL = [lookupJSON[@"termUrl"] asURL];
                      lookup.threeDSecureResult = [[BTThreeDSecureResult alloc] initWithJSON:body];
                      
                      completionBlock(lookup, nil);
                  }];
    }];
}

@end
