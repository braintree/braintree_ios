#import <UIKit/UIKit.h>

@class BTPaymentMethod;
@protocol BTPaymentMethodAuthorizationDelegate;

typedef NS_OPTIONS(NSInteger, BTPaymentButtonPaymentMethods) {
    BTPaymentButtonPaymentMethodVenmo,
    BTPaymentButtonPaymentMethodPayPal,
    BTPaymentButtonPaymentMethodAll = BTPaymentButtonPaymentMethodVenmo | BTPaymentButtonPaymentMethodPayPal,
};

@interface BTPaymentButton : UIView

@property (nonatomic, assign) BTPaymentButtonPaymentMethods paymentMethods;

@property (nonatomic, weak) id<BTPaymentMethodAuthorizationDelegate> delegate;

@end

@protocol BTPaymentMethodAuthorizationDelegate <NSObject>

#warning TODO document
- (BOOL)paymentMethodAuthorizer:(id)sender requestsUserChallengeWithViewController:(UIViewController *)viewController;

- (BOOL)paymentMethodAuthorizer:(id)sender requestsDismissalOfUserChallengeViewController:(UIViewController *)viewController;

- (void)paymentMethodAuthorizerWillRequestUserChallengeWithAppSwitch:(id)sender;

- (void)paymentMethodAuthorizerDidCompleteUserChallenge:(id)sender;

- (void)paymentMethodAuthorizer:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod;

- (void)paymentMethodAuthorizer:(id)sender didFailWithError:(NSError *)error;

@end