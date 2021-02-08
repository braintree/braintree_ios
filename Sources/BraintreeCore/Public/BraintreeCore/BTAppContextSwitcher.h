#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - BTAppContextSwitchDriver protocol

/**
 A protocol for handling the return from gathering payment information from a browser or another app.
 @note The app context may switch to a SFSafariViewController or to a native app, such as Venmo.
*/
@protocol BTAppContextSwitchDriver

@required

/**
 Determine whether the return URL can be handled.

 @param url the URL you receive in  `scene:openURLContexts:` (or `application:openURL:options:` if iOS 12) when returning to your app
 @return `YES` when the SDK can process the return URL
*/
+ (BOOL)canHandleReturnURL:(NSURL *)url NS_SWIFT_NAME(canHandleReturnURL(_:));

/**
 Complete payment flow after returning from app or browser switch.

 @param url The URL you receive in `scene:openURLContexts:` (or `application:openURL:options:` if iOS 12)
*/
+ (void)handleReturnURL:(NSURL *)url NS_SWIFT_NAME(handleReturnURL(_:));

@end

#pragma mark - BTAppContextSwitcher

/**
 Handles return URLs when returning from app context switch and routes the return URL to the correct app context switch driver class.
 @note `returnURLScheme` must contain your app's registered URL Type that starts with the app's bundle ID. When your app returns from app switch, the app delegate should call `handleOpenURL:` or `handleOpenURLContext:`
*/
@interface BTAppContextSwitcher : NSObject

/**
 The URL scheme to return to this app after switching to another app or opening a SFSafariViewController.
 
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
 SFSafariViewController or to another app to finish the payment authorization workflow.

 @param returnURLScheme The return URL scheme
*/
+ (void)setReturnURLScheme:(NSString *)returnURLScheme;

/**
 Handles a return from app context switch

 @param url The URL that was opened to return to your app
 @return `YES` if the app switch successfully handled the URL, or `NO` if the attempt to handle the URL failed.
*/
+ (BOOL)handleOpenURL:(NSURL *)url NS_SWIFT_NAME(handleOpenURL(_:));

/**
 Handles a return from app context switch

 @param URLContext The URLContext provided by `scene:openURLContexts:`
 @return `YES` if the app switch successfully handled the URLContext, or `NO` if the attempt to handle the URLContext failed.
*/
+ (BOOL)API_AVAILABLE(ios(13.0))handleOpenURLContext:(UIOpenURLContext *)URLContext NS_SWIFT_NAME(handleOpenURLContext(_:));

/**
 Registers a class that knows how to handle a return from app context switch
*/
- (void)registerAppContextSwitchDriver:(Class<BTAppContextSwitchDriver>)driver;

@end

NS_ASSUME_NONNULL_END
