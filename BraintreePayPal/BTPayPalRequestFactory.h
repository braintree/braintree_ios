#import <Foundation/Foundation.h>
#import "PayPalOneTouchRequest.h"
#import "PayPalOneTouchCore.h"

@interface BTPayPalRequestFactory : NSObject

/// Creates PayPal Express Checkout requests
- (PayPalOneTouchCheckoutRequest *)checkoutRequestWithApprovalURL:(NSURL *)approvalURL
                                                         clientID:(NSString *)clientID
                                                      environment:(NSString *)environment
                                                callbackURLScheme:(NSString *)callbackURLScheme;

/// Creates PayPal Billing Agreement requests
- (PayPalOneTouchBillingAgreementRequest *)billingAgreementRequestWithApprovalURL:(NSURL *)approvalURL
                                                                         clientID:(NSString *)clientID
                                                                      environment:(NSString *)environment
                                                                callbackURLScheme:(NSString *)callbackURLScheme;

/// Creates PayPal Future Payment requests
- (PayPalOneTouchAuthorizationRequest *)requestWithScopeValues:(NSSet *)scopeValues
                                                    privacyURL:(NSURL *)privacyURL
                                                  agreementURL:(NSURL *)agreementURL
                                                      clientID:(NSString *)clientID
                                                   environment:(NSString *)environment
                                             callbackURLScheme:(NSString *)callbackURLScheme;

@end
