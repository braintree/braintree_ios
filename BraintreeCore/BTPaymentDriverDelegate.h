#import <UIKit/UIKit.h>

/// Specifies the destination of an app switch
typedef NS_ENUM(NSInteger, BTAppSwitchTarget){
    /// Native app
    BTAppSwitchTargetNativeApp,
    /// Browser (i.e. Mobile Safari)
    BTAppSwitchTargetWebBrowser,
};

/// Protocol for receiving payment lifecycle messages from a driver tokenizing
/// some payment information, such as BTPayPalDriver, BTPaymentButton,
/// BTPaymentProvider and BTThreeDSecure.
@protocol BTPaymentDriverDelegate <NSObject>

@optional

/// The payment driver requires presentation of a view controller in order to
/// proceed.
///
/// Your implementation should present the viewController modally, e.g. via
/// `presentViewController:animated:completion:`
///
/// @param driver         The payment driver
/// @param viewController The view controller to be presented
- (void)paymentDriver:(id)driver requestsPresentationOfViewController:(UIViewController *)viewController;

/// The payment driver requires dismissal of a view controller.
///
/// Your implementation should dismiss the viewController, e.g. via
/// `dismissViewControllerAnimated:completion:`
///
/// @param driver         The payment driver
/// @param viewController The view controller to be dismissed
- (void)paymentDriver:(id)driver requestsDismissalOfViewController:(UIViewController *)viewController;

/// The payment driver will perform an app switch in order to obtain user
/// payment authorization.
///
/// Your implementation of this method may set your app to the state
/// it should be in if the user manually app-switches back to your app.
/// For example, re-enable any controls that are disabled.
///
/// @param driver The payment driver
- (void)paymentDriverWillPerformAppSwitch:(id)driver;

/// Delegates receive this message when the payment driver has successfully performed an app switch.
///
/// You may use this hook to prepare your UI for app switch return. Keep in mind that
/// users may manually switch back to your app via the iOS task manager.
///
/// @note You may also hook into the app switch lifecycle via UIApplicationWillResignActiveNotification.
///
/// @param driver The payment driver instance performing user authentication
/// @param target The destination that was actually used for this app switch
- (void)paymentDriver:(id)driver didPerformAppSwitchToTarget:(BTAppSwitchTarget)target;

/// The payment driver has obtained user payment details and/or user
/// authorization and will process the results.
///
/// This typically indicates asynchronous network activity.
/// When you receive this message, your UI should indicate activity.
///
/// In the case of an app switch, this message indicates that the user has returned to this app;
/// this is usually after handleAppSwitchReturnURL: is called in your UIApplicationDelegate.
///
/// @note You may also hook into the app switch lifecycle via UIApplicationWillResignActiveNotification.
///
/// @param driver The payment driver
- (void)paymentDriverWillProcessPaymentInfo:(id)driver;

@end
