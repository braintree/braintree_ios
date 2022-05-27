#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTVenmoRequest.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeVenmo/BTVenmoRequest.h>
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

@end

NS_ASSUME_NONNULL_END
