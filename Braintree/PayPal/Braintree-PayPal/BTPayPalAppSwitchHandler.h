#import <Foundation/Foundation.h>
#import "BTAppSwitchHandlerDelegate.h"

@class BTClient, BTPayPalPaymentMethod;

@interface BTPayPalAppSwitchHandler : NSObject

/// PayPal Touch: The custom URL scheme that the PayPal app should use to return users to your app via `openURL:` (app switch).
///
/// When `nil`, the button will not utilize PayPal Touch (app switch based auth) and fallback to an in app auth flow.
///
/// @note This must match the entry in your app's Info.plist, and must be prefixed
/// with your Bundle ID, e.g. com.yourcompany.Your-App.payment
@property (nonatomic, copy) NSString *appSwitchCallbackURLScheme;

@property (nonatomic, readonly, strong) BTClient *client;

@property (nonatomic, weak) id<BTAppSwitchHandlerDelegate>delegate;

+ (instancetype)sharedHandler;

- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id<BTAppSwitchHandlerDelegate>)delegate;

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

- (void)handleReturnURL:(NSURL *)url;

@end
