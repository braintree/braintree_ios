#import <UIKit/UIKit.h>

@protocol BTAppSwitchHandler;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - BTAppSwitch

/**
 Handles return URLs when returning from app switch and routes the return URL to the correct app switch handler class.
 @note `returnURLScheme` must contain your app's registered URL Type that starts with the app's bundleID. When your app returns from app switch, the app delegate should call `handleOpenURL:sourceApplication:`
*/
@interface BTAppSwitch : NSObject

/**
 The URL scheme to return to this app after switching to another app. 
 
 This URL scheme must be registered as a URL Type in the app's info.plist, and it must start with the app's bundle ID.
*/
@property (nonatomic, copy) NSString *returnURLScheme;

/**
 The singleton instance
*/
+ (instancetype)sharedInstance;

/**
 Sets the return URL scheme for your app.

 This must be configured if your app integrates a payment option that may switch to either
 Mobile Safari or to another app to finish the payment authorization workflow.

 @param returnURLScheme The return URL scheme
*/
+ (void)setReturnURLScheme:(NSString *)returnURLScheme;

/**
 Handles a return from app switch

 @param url The URL that was opened to return to your app
 @param sourceApplication The source app that requested the launch of your app
 @return `YES` if the app switch successfully handled the URL, or `NO` if the attempt to handle the URL failed.
*/
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication;

/**
 Handles a return from app switch

 @param url The URL that was opened to return to your app
 @param options The options dictionary provided by `application:openURL:options:`
 @return `YES` if the app switch successfully handled the URL, or `NO` if the attempt to handle the URL failed.
*/
+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary *)options;

/**
 Handles a return from app switch

 @param URLContext The URLContext provided by `scene:openURLContexts:`
 @return `YES` if the app switch successfully handled the URLContext, or `NO` if the attempt to handle the URLContext failed.
*/
+ (BOOL)API_AVAILABLE(ios(13.0))handleOpenURLContext:(UIOpenURLContext *)URLContext NS_SWIFT_NAME(handleOpenURLContext(_:));

/**
 Registers a class that knows how to handle a return from app switch
*/
- (void)registerAppSwitchHandler:(Class<BTAppSwitchHandler>)handler;

/**
 Unregisters a class that knows how to handle a return from app switch
*/
- (void)unregisterAppSwitchHandler:(Class<BTAppSwitchHandler>)handler;

/**
 Handles a return from app switch
 
 @param url The URL that was opened to return to your app
 @param sourceApplication The string representing the source application
 @return `YES` if the app switch successfully handled the URL, or `NO` if the attempt to handle the URL failed.
 */
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication DEPRECATED_MSG_ATTRIBUTE("Use handleOpenURL:options: or handleOpenURLContext: instead.");

@end

#pragma mark - BTAppSwitchDelegate

/**
 Notification that an app switch will occur
 */
extern NSString * const BTAppSwitchWillSwitchNotification;

/**
 Notification that an app switch did occur
 */
extern NSString * const BTAppSwitchDidSwitchNotification;

/**
 Notification that an app switch will process payment information
 */
extern NSString * const BTAppSwitchWillProcessPaymentInfoNotification;

/**
 Key for the target of an app switch notification
 
 @see BTAppSwitchTarget
 */
extern NSString * const BTAppSwitchNotificationTargetKey;

/**
 Notification that context will switch away from from the origin app
 */
extern NSString * const BTAppContextWillSwitchNotification;

/**
 Notification that the context switch has returned
 */
extern NSString * const BTAppContextDidReturnNotification;

/**
 Specifies the destination of an app switch
*/
typedef NS_ENUM(NSInteger, BTAppSwitchTarget) {
    /// Unknown error
    BTAppSwitchTargetUnknown = 0,

    /// Native app
    BTAppSwitchTargetNativeApp,

    /// Browser (i.e. Mobile Safari)
    BTAppSwitchTargetWebBrowser,
};

/**
 Protocol for receiving payment lifecycle messages from a payment option that may initiate an app or browser switch event to authorize payments.
*/
@protocol BTAppSwitchDelegate <NSObject>

/**
 The app switcher will perform an app switch in order to obtain user payment authorization.

 Your implementation of this method may set your app to the state
 it should be in if the user manually app-switches back to your app.
 For example, re-enable any controls that are disabled.

 @note Use `appContextWillSwitch:` to receive events for all types of context switching from the origin app to apps/browsers.

 @param appSwitcher The app switcher
*/
- (void)appSwitcherWillPerformAppSwitch:(id)appSwitcher;

/**
 Delegates receive this message when the app switcher has successfully performed an app switch.

 You may use this hook to prepare your UI for app switch return. Keep in mind that
 users may manually switch back to your app via the iOS task manager.

 @note You may also hook into the app switch lifecycle via UIApplicationWillResignActiveNotification.

 @param appSwitcher The app switcher instance performing user authentication
 @param target The destination that was actually used for this app switch
*/
- (void)appSwitcher:(id)appSwitcher didPerformSwitchToTarget:(BTAppSwitchTarget)target;

/**
 The app switcher has obtained user payment details and/or user authorization and will process the results.

 This typically indicates asynchronous network activity.
 When you receive this message, your UI should indicate activity.

 In the case of an app switch, this message indicates that the user has returned to this app;
 this is usually after handleAppSwitchReturnURL: is called in your UIApplicationDelegate.
 You may also hook into the app switch lifecycle via UIApplicationWillResignActiveNotification.

 @note Use `appContextDidReturn:` to receive events for all types of context switching from apps/browsers back to the origin app.

 @param appSwitcher The app switcher
*/
- (void)appSwitcherWillProcessPaymentInfo:(id)appSwitcher;

@optional

/**
 Regardless of the method (e.g. app, Safari, SFSafariViewController, SFAuthenticationSession) events will be sent when the context will switch away from from the origin app.

 @note Use this method to update UI (e.g. displaying a loading indicator) before the switch takes place.

 @param appSwitcher The app switcher
 */
- (void)appContextWillSwitch:(id)appSwitcher;

/**
 The context switch has returned.

 @note This is not guaranteed to be called. Example: A user leaves an app or Safari switch and manually returns to the origin app.

 @param appSwitcher The app switcher
 */
- (void)appContextDidReturn:(id)appSwitcher;

@end

#pragma mark - BTAppSwitchHandler protocol

/**
 A protocol for handling the return from switching out of an app to gather payment information.
 @note The app may switch out to Mobile Safari or to a native app.
*/
@protocol BTAppSwitchHandler

@required

/**
 Determine whether the app switch return URL can be handled.

 @param url the URL you receive in `application:openURL:sourceApplication:annotation` when returning to your app
 @param sourceApplication The source application you receive in `application:openURL:sourceApplication:annotation`
 @return `YES` when the object can handle returning from the application with a URL
*/
+ (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(NSString * _Nullable)sourceApplication;

/**
 Pass control back to `BTPayPalDriver` after returning from app or browser switch.

 @param url The URL you receive in `application:openURL:sourceApplication:annotation`
*/
+ (void)handleAppSwitchReturnURL:(NSURL *)url;

@optional

/**
 Indicates whether an iOS app is installed and available for app switch.
*/
- (BOOL)isiOSAppAvailableForAppSwitch;

@end

NS_ASSUME_NONNULL_END
