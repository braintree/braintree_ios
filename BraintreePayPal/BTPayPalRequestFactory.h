#import <Foundation/Foundation.h>
#import "PayPalOneTouchRequest.h"
#import "PayPalOneTouchCore.h"

@interface BTPayPalRequestFactory : NSObject

- (PayPalOneTouchCheckoutRequest *)requestWithApprovalURL:(NSURL *)approvalURL
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
