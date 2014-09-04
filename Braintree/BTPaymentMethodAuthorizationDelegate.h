// TODO: Documentation
// TODO: @optional vs. @required

@class BTPaymentMethod;

typedef NS_OPTIONS(NSInteger, BTPaymentMethodAuthorizationType) {
    BTPaymentMethodAuthorizationTypeCard  = 1 << 0,
    BTPaymentAuthorizationTypePayPal      = 1 << 1,
    BTPaymentMethodAuthorizationTypeVenmo = 1 << 2,
    BTPaymentMethodAuthorizationTypeAll   = BTPaymentMethodAuthorizationTypeCard | BTPaymentMethodAuthorizationTypeVenmo | BTPaymentAuthorizationTypePayPal,
};

@protocol BTPaymentMethodAuthorizationDelegate <NSObject>

- (BOOL)paymentMethodAuthorizer:(id)sender requestsUserChallengeWithViewController:(UIViewController *)viewController;

- (BOOL)paymentMethodAuthorizer:(id)sender requestsDismissalOfUserChallengeViewController:(UIViewController *)viewController;

- (void)paymentMethodAuthorizerWillRequestUserChallengeWithAppSwitch:(id)sender;

- (void)paymentMethodAuthorizerDidCompleteUserChallengeWithAppSwitch:(id)sender;

- (void)paymentMethodAuthorizer:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod;

- (void)paymentMethodAuthorizer:(id)sender didFailWithError:(NSError *)error;

- (void)paymentMethodAuthorizerDidCancel:(id)sender;

@end
