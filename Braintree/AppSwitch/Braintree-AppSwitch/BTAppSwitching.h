#import <Foundation/Foundation.h>
#import "BTClient.h"
#import "BTAppSwitchingDelegate.h"

@protocol BTAppSwitching <NSObject>

/// The custom URL scheme that the authenticating app should use to return users to your app via `openURL:` (app switch).
///
/// When `nil`, One Touch app switch will be disabled
///
/// @note This must match the entry in your app's Info.plist, and must be prefixed
/// with your Bundle ID, e.g. com.yourcompany.Your-App.payment
@property (nonatomic, copy) NSString *returnURLScheme;

@property (nonatomic, weak) id<BTAppSwitchingDelegate>delegate;

- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)delegate;

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

- (void)handleReturnURL:(NSURL *)url;

@end
