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

/// A delegate that receives messages throughout the app switch cycle
@property (nonatomic, weak) id<BTAppSwitchingDelegate>delegate;

///  Perform app switch
///
///  @param client   A BTClient needed for obtaining app switch configuration,
///                  and performing post-switch gateway operations.
///  @param delegate A delegate that will receive throughout the app switch cycle
///
///  @return whether app switch is occurring.
- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)delegate;

///  Whether this instance can be used to handle this response URL.
///
///  @param url
///  @param sourceApplication
///
///  @return Whether this instance can handle the given callback URL from
///  the given source application.
- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

///  Handle the actual response URL that contains payment authorization,
///  indication of cancellation, or error information.
///
///  @param url The callback response URL.
- (void)handleReturnURL:(NSURL *)url;

@end
