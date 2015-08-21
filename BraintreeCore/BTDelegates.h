#import <UIKit/UIKit.h>

extern NSString * const BTAppSwitchWillSwitchNotification;
extern NSString * const BTAppSwitchDidSwitchNotification;
extern NSString * const BTAppSwitchWillProcessPaymentInfoNotification;
extern NSString * const BTAppSwitchNotificationTargetKey;

/// Specifies the destination of an app switch
typedef NS_ENUM(NSInteger, BTAppSwitchTarget) {
    BTAppSwitchTargetUnknown = 0,
    /// Native app
    BTAppSwitchTargetNativeApp,
    /// Browser (i.e. Mobile Safari)
    BTAppSwitchTargetWebBrowser,
};

/// Protocol for receiving payment lifecycle messages from a payment option
/// that may initiate an app or browser switch event to authorize payments.
@protocol BTAppSwitchDelegate <NSObject>

/// The app switcher will perform an app switch in order to obtain user
/// payment authorization.
///
/// Your implementation of this method may set your app to the state
/// it should be in if the user manually app-switches back to your app.
/// For example, re-enable any controls that are disabled.
///
/// @param appSwitcher The app switcher
- (void)appSwitcherWillPerformAppSwitch:(id)appSwitcher;

/// Delegates receive this message when the app switcher has successfully performed an app switch.
///
/// You may use this hook to prepare your UI for app switch return. Keep in mind that
/// users may manually switch back to your app via the iOS task manager.
///
/// @note You may also hook into the app switch lifecycle via UIApplicationWillResignActiveNotification.
///
/// @param appSwitcher The app switcher instance performing user authentication
/// @param target The destination that was actually used for this app switch
- (void)appSwitcher:(id)appSwitcher didPerformSwitchToTarget:(BTAppSwitchTarget)target;

/// The app switcher has obtained user payment details and/or user
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
/// @param appSwitcher The app switcher
- (void)appSwitcherWillProcessPaymentInfo:(id)appSwitcher;

@end


/// Protocol for receiving payment lifecycle messages from a payment driver
/// that requires presentation of a view controller to authorize a payment.
@protocol BTViewControllerPresentingDelegate <NSObject>

/// The payment driver requires presentation of a view controller in order to proceed.
///
/// Your implementation should present the viewController modally, e.g. via
/// `presentViewController:animated:completion:`
///
/// @param driver         The payment driver
/// @param viewController The view controller to present
- (void)paymentDriver:(id)driver requestsPresentationOfViewController:(UIViewController *)viewController;

/// The payment driver requires dismissal of a view controller.
///
/// Your implementation should dismiss the viewController, e.g. via
/// `dismissViewControllerAnimated:completion:`
///
/// @param driver         The payment driver
/// @param viewController The view controller to be dismissed
- (void)paymentDriver:(id)driver requestsDismissalOfViewController:(UIViewController *)viewController;

@end
