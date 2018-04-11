#import <Foundation/Foundation.h>

#if __has_include("PayPalOneTouch.h")
#import "PPOTRequest.h"
#import "PPOTCore.h"
#else
#import <PayPalOneTouch/PPOTRequest.h>
#import <PayPalOneTouch/PPOTCore.h>
#endif

@interface BTPayPalRequestFactory : NSObject

/**
 Creates PayPal Express Checkout requests
*/
- (PPOTCheckoutRequest *)checkoutRequestWithApprovalURL:(NSURL *)approvalURL
                                               clientID:(NSString *)clientID
                                            environment:(NSString *)environment
                                      callbackURLScheme:(NSString *)callbackURLScheme;

/**
 Creates PayPal Billing Agreement requests
*/
- (PPOTBillingAgreementRequest *)billingAgreementRequestWithApprovalURL:(NSURL *)approvalURL
                                                               clientID:(NSString *)clientID
                                                            environment:(NSString *)environment
                                                      callbackURLScheme:(NSString *)callbackURLScheme;

/**
 Creates PayPal Future Payment requests
*/
- (PPOTAuthorizationRequest *)requestWithScopeValues:(NSSet *)scopeValues
                                          privacyURL:(NSURL *)privacyURL
                                        agreementURL:(NSURL *)agreementURL
                                            clientID:(NSString *)clientID
                                         environment:(NSString *)environment
                                   callbackURLScheme:(NSString *)callbackURLScheme;

@end
