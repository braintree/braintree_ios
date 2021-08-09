NS_ASSUME_NONNULL_BEGIN

//#pragma mark - BTAppContextSwitchDriver protocol
//
///**
// A protocol for handling the return from gathering payment information from a browser or another app.
// @note The app context may switch to a SFSafariViewController or to a native app, such as Venmo.
//*/
//@protocol BTAppContextSwitchDriver
//
//@required
//
///**
// Determine whether the return URL can be handled.
//
// @param url the URL you receive in  `scene:openURLContexts:` (or `application:openURL:options:` if iOS 12) when returning to your app
// @return `YES` when the SDK can process the return URL
//*/
//+ (BOOL)canHandleReturnURL:(NSURL *)url NS_SWIFT_NAME(canHandleReturnURL(_:));
//
///**
// Complete payment flow after returning from app or browser switch.
//
// @param url The URL you receive in `scene:openURLContexts:` (or `application:openURL:options:` if iOS 12)
//*/
//+ (void)handleReturnURL:(NSURL *)url NS_SWIFT_NAME(handleReturnURL(_:));
//
//@end


NS_ASSUME_NONNULL_END
