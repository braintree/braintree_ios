#import <Foundation/Foundation.h>
@class PPOTCheckoutRequest;
@class PPOTBillingAgreementRequest;
@class PPOTAuthorizationRequest;

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
