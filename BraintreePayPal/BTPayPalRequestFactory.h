#import <Foundation/Foundation.h>
#import "PayPalOneTouchRequest.h"
#import "PayPalOneTouchCore.h"

@interface BTPayPalRequestFactory : NSObject

- (PayPalOneTouchCheckoutRequest *)checkoutRequestWithApprovalURL:(NSURL *)approvalURL
                                                         clientID:(NSString *)clientID
                                                      environment:(NSString *)environment
                                                callbackURLScheme:(NSString *)callbackURLScheme;

- (PayPalOneTouchBillingAgreementRequest *)billingAgreementRequestWithApprovalURL:(NSURL *)approvalURL
                                                                         clientID:(NSString *)clientID
                                                                      environment:(NSString *)environment
                                                                callbackURLScheme:(NSString *)callbackURLScheme;

- (PayPalOneTouchAuthorizationRequest *)requestWithScopeValues:(NSSet *)scopeValues
                                                    privacyURL:(NSURL *)privacyURL
                                                  agreementURL:(NSURL *)agreementURL
                                                      clientID:(NSString *)clientID
                                                   environment:(NSString *)environment
                                             callbackURLScheme:(NSString *)callbackURLScheme;

@end
