#import "BTPayPalRequestFactory.h"

@implementation BTPayPalRequestFactory

- (PayPalOneTouchCheckoutRequest *)requestWithApprovalURL:(NSURL *)approvalURL
                                                 clientID:(NSString *)clientID
                                              environment:(NSString *)environment
                                        callbackURLScheme:(NSString *)callbackURLScheme
{
    return [PayPalOneTouchCheckoutRequest requestWithApprovalURL:approvalURL
                                                        clientID:clientID
                                                     environment:environment
                                               callbackURLScheme:callbackURLScheme];
}

@end
