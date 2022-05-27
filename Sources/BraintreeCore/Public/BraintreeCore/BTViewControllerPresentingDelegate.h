#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol for receiving payment lifecycle messages from a payment client that requires presentation of a view controller to authorize a payment.
*/
@protocol BTViewControllerPresentingDelegate <NSObject>

/**
 The payment client requires presentation of a view controller in order to proceed.

 Your implementation should present the viewController modally, e.g. via
 `presentViewController:animated:completion:`

 @param client         The payment client
 @param viewController The view controller to present
*/
- (void)paymentClient:(id)client requestsPresentationOfViewController:(UIViewController *)viewController;

/**
 The payment client requires dismissal of a view controller.

 Your implementation should dismiss the viewController, e.g. via
 `dismissViewControllerAnimated:completion:`

 @param client         The payment client
 @param viewController The view controller to be dismissed
*/
- (void)paymentClient:(id)client requestsDismissalOfViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
