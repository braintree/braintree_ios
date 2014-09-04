@import UIKit;

@class BTPaymentMethod;

typedef NS_ENUM(NSInteger, BTPaymentAuthorizationType) {
    BTPaymentAuthorizationTypePayPal,
    BTPaymentAuthorizationTypeVenmo
};

/// Protocol for receiving authorization lifecycle messages from a payment authorizer
@protocol BTPaymentAuthorizerDelegate <NSObject>

///  The payment authorizer requires presentation of a view controller in order to
///  obtain user payment authorization.
///
///  @param sender         The payment authorizer
///  @param viewController The view controller to be presented
///
///  @return Whether the view controller was presented.
- (BOOL)paymentAuthorizer:(id)sender requestsUserChallengeWithViewController:(UIViewController *)viewController;

///  The payment authorizer has completed and requires dismissal of a view controller.
///
///  @param sender         The payment authorizer
///  @param viewController The view controller to be presented
///
///  @return Whether the view controller was dismissed.
- (BOOL)paymentAuthorizer:(id)sender requestsDismissalOfUserChallengeViewController:(UIViewController *)viewController;

///  The payment authorizer will perform an app switch in order to obtain user
///  payment authorization.
///
///  @param sender The payment authorizer
- (void)paymentAuthorizerWillRequestUserChallengeWithAppSwitch:(id)sender;

///  The payment authorizer, having performed an app switch in order to obtain user
///  payment authorization, has received results from the app switch and will use
///  those results to create a payment method.
///
///  @param sender The payment authorizer
- (void)paymentAuthorizerDidCompleteUserChallengeWithAppSwitch:(id)sender;

///  The payment authorizer received authorization, which it then successfully
///  used to create a payment method.
///
///  @param sender        The payment authorizer
///  @param paymentMethod The resulting payment method
- (void)paymentAuthorizer:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod;

///  The payment authorizer failed to create a payment method.
///
///  @param sender The payment authorizer
///  @param error  An error that characterizes the failure
- (void)paymentAuthorizer:(id)sender didFailWithError:(NSError *)error;

@end
