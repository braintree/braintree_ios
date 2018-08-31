#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTVenmoAccountNonce.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Domain for Venmo errors.
 */
extern NSString * const BTVenmoDriverErrorDomain;

/**
 Error codes associated with Venmo.
 */
typedef NS_ENUM(NSInteger, BTVenmoDriverErrorType) {
    /// Unknown error
    BTVenmoDriverErrorTypeUnknown = 0,
    
    /// Venmo is disabled in configuration
    BTVenmoDriverErrorTypeDisabled,
    
    /// App is not installed on device
    BTVenmoDriverErrorTypeAppNotAvailable,
    
    /// Bundle display name must be present
    BTVenmoDriverErrorTypeBundleDisplayNameMissing,
    
    /// UIApplication failed to switch to Venmo app
    BTVenmoDriverErrorTypeAppSwitchFailed,
    
    /// Return URL was invalid
    BTVenmoDriverErrorTypeInvalidReturnURL,
    
    /// Braintree SDK is integrated incorrectly
    BTVenmoDriverErrorTypeIntegration,
    
    /// Request URL was invalid, configuration may be missing required values
    BTVenmoDriverErrorTypeInvalidRequestURL,
};

/**
 Used to process Venmo payments
 */
@interface BTVenmoDriver : NSObject <BTAppSwitchHandler>

/**
 Initialize a new Venmo driver instance.

 @param apiClient The API client
*/
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

/**
 Initiates Venmo login via app switch, which returns a BTVenmoAccountNonce when successful.

 @param vault Whether to automatically vault the Venmo Account. Vaulting will only occur if a client token with a customer_id is being used.
 @param completionBlock This completion will be invoked when app switch is complete or an error occurs.
    On success, you will receive an instance of `BTVenmoAccountNonce`; on failure, an error; on user
    cancellation, you will receive `nil` for both parameters.
*/
- (void)authorizeAccountAndVault:(BOOL)vault completion:(void (^)(BTVenmoAccountNonce * _Nullable venmoAccount, NSError * _Nullable error))completionBlock;

/**
 Initiates Venmo login via app switch, which returns a BTVenmoAccountNonce when successful.

 @param profileId The Venmo profile ID to be used during payment authorization. Customers will see the business name and logo associated with this Venmo profile, and it will show up in the Venmo app as a "Connected Merchant". Venmo profile IDs can be found in the Braintree Control Panel. Passing `nil` will use the default Venmo profile.
 @param vault Whether to automatically vault the Venmo Account. Vaulting will only occur if a client token with a customer_id is being used.
 @param completionBlock This completion will be invoked when app switch is complete or an error occurs.
 On success, you will receive an instance of `BTVenmoAccountNonce`; on failure, an error; on user
 cancellation, you will receive `nil` for both parameters.
 */
- (void)authorizeAccountWithProfileID:(nullable NSString *)profileId vault:(BOOL)vault completion:(void (^)(BTVenmoAccountNonce * _Nullable venmoAccount, NSError * _Nullable error))completionBlock NS_SWIFT_NAME(authorizeAccount(profileID:vault:completion:));

/**
 Initiates Venmo login via app switch, which returns a BTVenmoAccountNonce when successful.

 @param completionBlock This completion will be invoked when app switch is complete or an error occurs.
    On success, you will receive an instance of `BTVenmoAccountNonce`; on failure, an error; on user
    cancellation, you will receive `nil` for both parameters.
*/
- (void)authorizeAccountWithCompletion:(void (^)(BTVenmoAccountNonce * _Nullable venmoAccount, NSError * _Nullable error))completionBlock DEPRECATED_MSG_ATTRIBUTE("Use [BTVenmoDriver authorizeAccountAndVault:completion instead");

/**
 Returns true if the proper Venmo app is installed and configured correctly, returns false otherwise.
*/
- (BOOL)isiOSAppAvailableForAppSwitch;

/**
 Switches to the iTunes App Store to download the Venmo app.
 */
- (void)openVenmoAppPageInAppStore;

/**
 An optional delegate for receiving notifications about the lifecycle of a Venmo app switch, as well as updating your UI
*/
@property (nonatomic, weak, nullable) id<BTAppSwitchDelegate> appSwitchDelegate;

@end

NS_ASSUME_NONNULL_END
