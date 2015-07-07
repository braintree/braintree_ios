#import <Foundation/Foundation.h>
#import "BTAPIClient.h"
#import "BTNullability.h"
#import "BTTokenizedPayPalAccount.h"
#import "BTTokenizedPayPalCheckout.h"
#import "BTPayPalCheckoutRequest.h"

BT_ASSUME_NONNULL_BEGIN

/// App Switch NSError Domain
extern NSString *const BTPayPalDriverErrorDomain;

/// App Switch NSError Codes
typedef NS_ENUM(NSInteger, BTPayPalDriverErrorCode) {
    BTPayPalDriverErrorCodeUnknown = 0,

    /// A compatible version of the target app is not available on this device.
    BTPayPalDriverErrorCodeAppNotAvailable = 1,

    /// App switch is not enabled.
    BTPayPalDriverErrorCodeDisabled = 2,

    /// App switch is not configured appropriately. You must specify a
    /// valid returnURLScheme via Braintree before attempting an app switch.
    BTPayPalDriverErrorCodeIntegrationReturnURLScheme = 3,

    /// The merchant ID field was not valid or present in the client token.
    BTPayPalDriverErrorCodeIntegrationMerchantId = 4,

    /// UIApplication failed to switch despite it being available.
    /// `[UIApplication openURL:]` returned `NO` when `YES` was expected.
    BTPayPalDriverErrorCodeFailed = 5,

    /// App switch completed, but the client encountered an error while attempting
    /// to communicate with the Braintree server.
    /// Check for a `NSUnderlyingError` value in the `userInfo` dictionary for information
    /// about the underlying cause.
    BTPayPalDriverErrorCodeFailureFetchingPaymentMethod = 6,

    /// Parameters used to initiate app switch are invalid
    BTPayPalDriverErrorCodeIntegrationInvalidParameters = 7,

    /// Invalid CFBundleDisplayName
    BTPayPalDriverErrorCodeIntegrationInvalidBundleDisplayName = 8,

    BTPayPalDriverErrorCodeUnknownError = 9,

    BTPayPalDriverErrorCodePayPalConfiguration = 10,

    /// PayPal is disabled
    BTPayPalDriverErrorCodePayPalDisabled = 11,
};

@protocol BTPayPalDriverDelegate;

@interface BTPayPalDriver : NSObject

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient returnURLScheme:(NSString *)returnURLScheme;

@property (nonatomic, copy) NSString *clientToken DEPRECATED_MSG_ATTRIBUTE("Delete me as soon as possible. BTPayPalDriver only requires a client token due to Browser-Switch requiring a client token.");

- (void)authorizeAccountWithCompletion:(void (^)(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error))completionBlock;

- (void)authorizeAccountWithAdditionalScopes:(NSSet<NSString *> *)additionalScopes completion:(void (^)(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error))completionBlock;

- (void)checkoutWithCheckoutRequest:(BTPayPalCheckoutRequest *)checkoutRequest completion:(void (^)(__BT_NULLABLE BTTokenizedPayPalCheckout *tokenizedPayPalCheckout, __BT_NULLABLE NSError *error))completionBlock;

#pragma mark - App Switch

/// Determine whether the app switch return is valid for being handled by this instance
///
/// @param url the URL you receive in application:openURL:sourceApplication:annotation when PayPal returns back to your app
/// @param sourceApplication the sourceApplication you receive in application:openURL:sourceApplication:annotation when PayPal returns back to your app
+ (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

/// Pass control back into BTPayPalDriver after an app switch return. You must call this method in application:openURL:sourceApplication:annotation.
///
/// @param url the URL you receive in application:openURL:sourceApplication:annotation when PayPal returns back to your app
+ (void)handleAppSwitchReturnURL:(NSURL *)url;


#pragma mark - Delegate

/// An optional delegate for receiving notifications about the lifecycle of a PayPal app switch for updating your UI
@property (nonatomic, weak, nullable) id<BTPayPalDriverDelegate> delegate;

@end


/// Specifies the destination of the PayPal app switch
typedef NS_ENUM(NSInteger, BTPayPalDriverAppSwitchTarget){
    /// Login or One Touch will take place in the PayPal app
    BTPayPalDriverAppSwitchTargetPayPalApp,
    /// Login or One Touch will take place in the browser on PayPal's website
    BTPayPalDriverAppSwitchTargetBrowser,
};

/// A delegate protocol for sending lifecycle updates as PayPal login via app switch takes place
@protocol BTPayPalDriverDelegate <NSObject>

@optional

/// Delegates receive this message when the PayPal driver is preparing to perform an app switch.
///
/// This transition is usually instantaneous; however, you may use this hook to present a loading
/// indication to the user.
///
/// @param payPalDriver The BTPayPalDriver instance performing user authentication
- (void)payPalDriverWillPerformAppSwitch:(BTPayPalDriver *)payPalDriver;

/// Delegates receive this message when the PayPal driver has successfully performed an app switch.
///
/// You may use this hook to prepare your UI for app switch return. Keep in mind that
/// users may manually switch back to your app via the iOS task manager.
///
/// @note You may also hook into the app switch lifecycle via UIApplicationWillResignActiveNotification.
///
/// @param payPalDriver The BTPayPalDriver instance performing user authentication
/// @param target       The destination that was actually used for this app switch
- (void)payPalDriver:(BTPayPalDriver *)payPalDriver didPerformAppSwitchToTarget:(BTPayPalDriverAppSwitchTarget)target;

/// Delegates receive this message when control returns to BTPayPalDriver upon app switch return
///
/// This usually gets invoked after handleAppSwitchReturnURL: is called in your UIApplicationDelegate.
///
/// @note You may also hook into the app switch lifecycle via UIApplicationWillResignActiveNotification.
///
/// @param payPalDriver The instance of BTPayPalDriver handling the app switch return.
- (void)payPalDriverWillProcessAppSwitchResult:(BTPayPalDriver *)payPalDriver;

@end

BT_ASSUME_NONNULL_END

