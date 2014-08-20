#import <Foundation/Foundation.h>

@class BTClient, BTPayPalPaymentMethod;
@protocol BTPayPalAppSwitchHandlerDelegate;

@interface BTPayPalAppSwitchHandler : NSObject

/// PayPal Touch: The custom URL scheme that the PayPal app should use to return users to your app via `openURL:` (app switch).
///
/// When `nil`, the button will not utilize PayPal Touch (app switch based auth) and fallback to an in app auth flow.
///
/// @note This must match the entry in your app's Info.plist, and must be prefixed
/// with your Bundle ID, e.g. com.yourcompany.Your-App.payment
@property (nonatomic, copy) NSString *appSwitchCallbackURLScheme;

@property (nonatomic, readonly, strong) BTClient *client;

@property (nonatomic, weak) id<BTPayPalAppSwitchHandlerDelegate>delegate;


+ (instancetype)sharedHandler;

- (BOOL)initiatePayPalAuthWithClient:(BTClient *)client delegate:(id<BTPayPalAppSwitchHandlerDelegate>)delegate;

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

- (void)handleReturnURL:(NSURL *)url;

@end


/// Delegate protocol for receiving messages about state changes to a `BTPayPalappSwitchHandler`
///
/// @see BTPayPalAppSwitchHandler
@protocol BTPayPalAppSwitchHandlerDelegate <NSObject>

@optional

/// This message is sent immediately before app switch will be initiated.
///
/// @param appSwitchHandler
- (void)payPalAppSwitchHandlerWillAppSwitch:(BTPayPalAppSwitchHandler *)appSwitchHandler;

/// This message is sent when the user has authorized PayPal, and the payment method
/// is about to be created.
///
/// @param appSwitchHandler
- (void)payPalAppSwitchHandlerWillCreatePayPalPaymentMethod:(BTPayPalAppSwitchHandler *)appSwitchHandler;

@required

/// This message is sent when a payment method has been authorized and is available.
///
/// @param appSwitchHandler The requesting `BTPayPalAppSwitchHandler`
/// @param nonce
- (void)payPalAppSwitchHandler:(BTPayPalAppSwitchHandler *)appSwitchHandler didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod;

/// This message is sent when the payment method could not be created.
///
/// @param
- (void)payPalAppSwitchHandler:(BTPayPalAppSwitchHandler *)appSwitchHandler didFailWithError:(NSError *)error;

- (void)payPalAppSwitchHandlerAuthenticatorAppDidCancel:(BTPayPalAppSwitchHandler *)appSwitchHandler;

@end