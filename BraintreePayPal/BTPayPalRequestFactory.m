#import "BTPayPalRequestFactory.h"

@implementation BTPayPalRequestFactory

/// Creates checkout (Single Payments) requests for PayPal
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

/// Creates billing agreement requests for PayPal
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

/// Creates authorization (Future Payments) requests for PayPal
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
