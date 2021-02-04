#import <UIKit/UIKit.h>

@protocol BTAppContextSwitchDriver;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - BTAppContextSwitcher

/**
 Handles return URLs when returning from app switch and routes the return URL to the correct app switch handler class.
 @note `returnURLScheme` must contain your app's registered URL Type that starts with the app's bundleID. When your app returns from app switch, the app delegate should call `handleOpenURL:` or `handleOpenURLContext:`
*/
@interface BTAppContextSwitcher : NSObject

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
 @return `YES` if the app switch successfully handled the URL, or `NO` if the attempt to handle the URL failed.
*/
+ (BOOL)handleOpenURL:(NSURL *)url;

/**
 Handles a return from app switch

 @param URLContext The URLContext provided by `scene:openURLContexts:`
 @return `YES` if the app switch successfully handled the URLContext, or `NO` if the attempt to handle the URLContext failed.
*/
+ (BOOL)API_AVAILABLE(ios(13.0))handleOpenURLContext:(UIOpenURLContext *)URLContext NS_SWIFT_NAME(handleOpenURLContext(_:));

/**
 Registers a class that knows how to handle a return from app switch
*/
- (void)registerAppContextSwitchDriver:(Class<BTAppContextSwitchDriver>)handler;

/**
 Unregisters a class that knows how to handle a return from app switch
*/
- (void)unregisterAppContextSwitchHandler:(Class<BTAppContextSwitchDriver>)handler;

@end

#pragma mark - BTAppContextSwitchDelegate

/**
 Protocol for receiving payment lifecycle messages from a payment option that may initiate an app or browser switch event to authorize payments.
*/
@protocol BTAppContextSwitchDelegate <NSObject>

@optional

/**
 Delegates receive this message when the app switcher has successfully performed an app switch.

 You may use this hook to prepare your UI for app switch return. Keep in mind that
 users may manually switch back to your app via the iOS task manager.

 @note You may also hook into the app switch lifecycle via UIApplicationWillResignActiveNotification.

 @param driver The app switcher instance performing user authentication
*/
- (void)appContextSwitchDriverDidStartSwitch:(id<BTAppContextSwitchDriver>)driver;

/**
 Regardless of the method (e.g. app, Safari, SFSafariViewController, ASWebAuthenticationSession) events will be sent when the context will switch away from from the origin app.

 @note Use this method to update UI (e.g. displaying a loading indicator) before the switch takes place.

 @param driver The app switcher
 */
- (void)appContextSwitchDriverWillStartSwitch:(id<BTAppContextSwitchDriver>)driver;

/**
 The context switch has returned.

 @note This is not guaranteed to be called. Example: A user leaves an app manually returns to the origin app.

 @param appSwitcher The app switcher
 */
- (void)appContextSwitchDriverDidCompleteSwitch:(id<BTAppContextSwitchDriver>)driver;

@end

#pragma mark - BTAppContextSwitchDriver protocol

/**
 A protocol for handling the return from switching out of an app to gather payment information.
 @note The app may switch out to SFSafariViewController or to a native app.
*/
@protocol BTAppContextSwitchDriver

@required

/**
 Determine whether the app switch return URL can be handled.

 @param url the URL you receive in  `scene:openURLContexts:` (or `application:openURL:options:` if iOS 12) when returning to your app
 @return `YES` when the object can handle returning from the application with a URL
*/
+ (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url;

/**
 Complete payment flow after returning from app or browser switch.

 @param url The URL you receive in `scene:openURLContexts:` (or `application:openURL:options:` if iOS 12)
*/
+ (void)handleAppSwitchReturnURL:(NSURL *)url;

@optional

/**
 Indicates whether an iOS app is installed and available for app switch.
*/
- (BOOL)isiOSAppAvailableForAppSwitch; // TODO: - make static?

@end

NS_ASSUME_NONNULL_END
