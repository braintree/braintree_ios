@import UIKit;

@class BTPaymentMethod;

typedef NS_ENUM(NSInteger, BTPaymentAuthorizationType) {
    BTPaymentAuthorizationTypePayPal,
    BTPaymentAuthorizationTypeVenmo
};

@protocol BTPaymentAuthorizerDelegate <NSObject>

- (BOOL)paymentAuthorizer:(id)sender requestsUserChallengeWithViewController:(UIViewController *)viewController;

- (BOOL)paymentAuthorizer:(id)sender requestsDismissalOfUserChallengeViewController:(UIViewController *)viewController;

- (void)paymentAuthorizerWillRequestUserChallengeWithAppSwitch:(id)sender;

- (void)paymentAuthorizerDidCompleteUserChallengeWithAppSwitch:(id)sender;

- (void)paymentAuthorizer:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod;

- (void)paymentAuthorizer:(id)sender didFailWithError:(NSError *)error;

@end
