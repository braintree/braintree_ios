#import <Foundation/Foundation.h>
#import "BTClient.h"
#import "BTAppSwitchHandlerDelegate.h"

@interface BTVenmoAppSwitchHandler : NSObject

/// Venmo Touch: The custom URL scheme that the Venmo app should use to return users to your app via `openURL:` (app switch).
///
/// When `nil`, the `initiateAppSwitchWithClient:delegate:` call will return NO.
///
/// @note This must match the entry in your app's Info.plist, and must be prefixed
/// with your Bundle ID, e.g. com.yourcompany.Your-App.payment
@property (nonatomic, copy) NSString *returnURLScheme;

@property (nonatomic, readonly, strong) BTClient *client;

@property (nonatomic, weak) id<BTAppSwitchHandlerDelegate>delegate;

+ (instancetype)sharedHandler;

- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id<BTAppSwitchHandlerDelegate>)delegate;

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

- (void)handleReturnURL:(NSURL *)url;

@end

