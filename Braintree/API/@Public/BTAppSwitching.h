#import <Foundation/Foundation.h>

#import "BTClient.h"
#import "BTAppSwitchingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

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

/// Checks integration setup and presence of app on device to determine
/// if app switch is available for the given client.
///
/// @param client A BTClient
///
/// @return       Whether app switch is available
- (BOOL)appSwitchAvailableForClient:(BTClient*)client;

///  Attempt to initiate app switch
///
///  @param client   A BTClient needed for obtaining app switch configuration,
///                  reporting analytics events, and performing post-switch
///                  gateway operations.
///  @param delegate A delegate that will receive messags throughout the app
///                  switch cycle after successful initiation.
///
///  @param error    Error encountered in attempting to app switch if applicable.
///
///  @return whether app switch is occurring.
- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)delegate error:(NSError * __autoreleasing *)error;

///  Whether this instance can be used to handle this response URL.
///
///  @param url A URL string.
///  @param sourceApplication The source application.
///
///  @return Whether this instance can handle the given callback URL from
///  the given source application.
- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication;

///  Handle the actual response URL that contains payment authorization,
///  indication of cancellation, or error information.
///
///  @param url The callback response URL.
- (void)handleReturnURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
