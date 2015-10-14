#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Use this class to handle app switch, which requires global state.
/// For the entrypoint into the Braintree API, see BTAPIClient.
///
/// @see BTAPIClient

@interface Braintree : NSObject


/// Sets the return URL scheme for your app.
///
/// This must be configured if your app integrates a payment option that may switch to either
/// Mobile Safari or to another app to finish the payment authorization workflow.
///
/// @param returnURLScheme The return URL scheme
+ (void)setReturnURLScheme:(NSString *)returnURLScheme;


/// Handles a return from app switch
/// @param url The URL that was opened to return to your app
/// @param sourceApplication The source app that requested the launch of your app
/// @return `YES` if the URL was handled
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication;


/// Handles a return from app switch
/// @param url The URL that was opened to return to your app
/// @param options The options dictionary provided by `application:openURL:options:`
/// @return `YES` if the URL was handled
+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary *)options;


@end

NS_ASSUME_NONNULL_END
