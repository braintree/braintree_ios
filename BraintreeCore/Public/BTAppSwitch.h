#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// @protocol BTAppSwitchHandler
/// @description A protocol for handling the return from switching out of an app to gather payment information.
/// The app may switch out to Mobile Safari or to a native app.
@protocol BTAppSwitchHandler

@required

/// Determine whether the app switch return URL can be handled.
///
/// @param url the URL you receive in `application:openURL:sourceApplication:annotation` when returning to
/// your app
/// @param sourceApplication The source application you receive in `application:openURL:sourceApplication:annotation`
/// @return `YES` when the object can handle returning from the application with a URL
+ (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

/// Pass control back to `BTPayPalDriver` after returning from app or browser switch.
///
/// @param url The URL you receive in `application:openURL:sourceApplication:annotation`
+ (void)handleAppSwitchReturnURL:(NSURL *)url;

@optional

/// Indicates whether an iOS app is installed and available for app switch.
- (BOOL)isiOSAppAvailableForAppSwitch;

@end

/// @class BTAppSwitch
/// @description Handles return URLs when returning from app switch and routes the return URL to the correct
/// app switch handler class.
/// @note `returnURLScheme` must contain your app's registered URL Type that starts with the app's bundle
/// ID. When your app returns from app switch, the app delegate should call `handleOpenURL:sourceApplication:`
@interface BTAppSwitch : NSObject

/// The URL scheme to return to this app after switching to another app. This URL scheme must be registered
/// as a URL Type in the app's info.plist, and it must start with the app's bundle ID.
@property (nonatomic, copy) NSString *returnURLScheme;

/// The singleton instance
+ (instancetype)sharedInstance;

/// Sets the return URL scheme for your app.
///
/// This must be configured if your app integrates a payment option that may switch to either
/// Mobile Safari or to another app to finish the payment authorization workflow.
///
/// @param returnURLScheme The return URL scheme
+ (void)setReturnURLScheme:(NSString *)returnURLScheme;

/// Handles a return from app switch
///
/// @param url The URL that was opened to return to your app
/// @param sourceApplication The source app that requested the launch of your app
/// @return `YES` if the app switch successfully handled the URL, or `NO` if the attempt to handle the URL failed.
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

/// Handles a return from app switch
///
/// @param url The URL that was opened to return to your app
/// @param options The options dictionary provided by `application:openURL:options:`
/// @return `YES` if the app switch successfully handled the URL, or `NO` if the attempt to handle the URL failed.
+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary *)options;

/// Registers a class that knows how to handle a return from app switch
- (void)registerAppSwitchHandler:(Class<BTAppSwitchHandler>)handler;

/// Unregisters a class that knows how to handle a return from app switch
- (void)unregisterAppSwitchHandler:(Class<BTAppSwitchHandler>)handler;

@end

NS_ASSUME_NONNULL_END
