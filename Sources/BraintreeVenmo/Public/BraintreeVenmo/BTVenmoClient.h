#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTVenmoRequest.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeVenmo/BTVenmoRequest.h>
#endif

// Swift Module Imports
#if __has_include(<Braintree/Braintree-Swift.h>) // Cocoapods-generated Swift Header
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCoreSwift;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else // Carthage or Local Builds
#import <BraintreeCoreSwift/BraintreeCoreSwift-Swift.h>
#endif

@class BTVenmoAccountNonce;

NS_ASSUME_NONNULL_BEGIN

/**
 Domain for Venmo errors.
 */
extern NSString * const BTVenmoErrorDomain;

/**
 Error codes associated with Venmo.
 */
typedef NS_ENUM(NSInteger, BTVenmoErrorType) {
    /// Unknown error
    BTVenmoErrorTypeUnknown = 0,
    
    /// Venmo is disabled in configuration
    BTVenmoErrorTypeDisabled,
    
    /// App is not installed on device
    BTVenmoErrorTypeAppNotAvailable,
    
    /// Bundle display name must be present
    BTVenmoErrorTypeBundleDisplayNameMissing,
    
    /// UIApplication failed to switch to Venmo app
    BTVenmoErrorTypeAppSwitchFailed,
    
    /// Return URL was invalid
    BTVenmoErrorTypeInvalidReturnURL,
    
    /// Braintree SDK is integrated incorrectly
    BTVenmoErrorTypeIntegration,
    
    /// Request URL was invalid, configuration may be missing required values
    BTVenmoErrorTypeInvalidRequestURL,
};

/**
 Used to process Venmo payments
 */
@interface BTVenmoClient : NSObject <BTAppContextSwitchClient>

/**
 Initialize a new Venmo client instance.

 @param apiClient The API client
*/
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

/**
 Initiates Venmo login via app switch, which returns a BTVenmoAccountNonce when successful.

 @param venmoRequest A Venmo request.
 @param completionBlock This completion will be invoked when app switch is complete or an error occurs.
    On success, you will receive an instance of `BTVenmoAccountNonce`; on failure, an error; on user
    cancellation, you will receive `nil` for both parameters.
*/
- (void)tokenizeVenmoAccountWithVenmoRequest:(BTVenmoRequest *)venmoRequest completion:(void (^)(BTVenmoAccountNonce * _Nullable venmoAccount, NSError * _Nullable error))completionBlock;

/**
 Returns true if the proper Venmo app is installed and configured correctly, returns false otherwise.
*/
- (BOOL)isiOSAppAvailableForAppSwitch;

/**
 Switches to the iTunes App Store to download the Venmo app.
 */
- (void)openVenmoAppPageInAppStore;

/// :nodoc: exposed for unit testing
+ (void)handleReturnURL:(NSURL * _Nonnull)url;

/// :nodoc: exposed for unit testing
+ (BOOL)canHandleReturnURL:(NSURL * _Nonnull)url SWIFT_WARN_UNUSED_RESULT;

@end

NS_ASSUME_NONNULL_END
