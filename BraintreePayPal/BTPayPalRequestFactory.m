#import "BTPayPalRequestFactory.h"

@implementation BTPayPalRequestFactory

- (PayPalOneTouchCheckoutRequest *)checkoutRequestWithApprovalURL:(NSURL *)approvalURL
                                                         clientID:(NSString *)clientID
                                                      environment:(NSString *)environment
                                                callbackURLScheme:(NSString *)callbackURLScheme
{
    return [PayPalOneTouchCheckoutRequest requestWithApprovalURL:approvalURL
                                                       pairingId:[PayPalOneTouchRequest tokenFromApprovalURL:approvalURL]
                                                        clientID:clientID
                                                     environment:environment
                                               callbackURLScheme:callbackURLScheme];
}

- (PayPalOneTouchBillingAgreementRequest *)billingAgreementRequestWithApprovalURL:(NSURL *)approvalURL
                                                                         clientID:(NSString *)clientID
                                                                      environment:(NSString *)environment
                                                                callbackURLScheme:(NSString *)callbackURLScheme
{
    return [PayPalOneTouchBillingAgreementRequest requestWithApprovalURL:approvalURL
                                                               pairingId:[PayPalOneTouchRequest tokenFromApprovalURL:approvalURL]
                                                                clientID:clientID
                                                             environment:environment
                                                       callbackURLScheme:callbackURLScheme];
}

- (PayPalOneTouchAuthorizationRequest *)requestWithScopeValues:(NSSet *)scopeValues
                                                    privacyURL:(NSURL *)privacyURL
                                                  agreementURL:(NSURL *)agreementURL
                                                      clientID:(NSString *)clientID
                                                   environment:(NSString *)environment
                                             callbackURLScheme:(NSString *)callbackURLScheme
{
    return [PayPalOneTouchAuthorizationRequest requestWithScopeValues:scopeValues
                                                           privacyURL:privacyURL
                                                         agreementURL:agreementURL
                                                             clientID:clientID
                                                          environment:environment
                                                    callbackURLScheme:callbackURLScheme];
}

@end
