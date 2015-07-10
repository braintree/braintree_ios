#import <Foundation/Foundation.h>
#import "BTAPIClient.h"
#import "BTNullability.h"
#import "BTTokenizedPayPalAccount.h"
#import "BTTokenizedPayPalCheckout.h"
#import "BTPayPalCheckoutRequest.h"

extern NSString *const BTPayPalDriverErrorDomain;

typedef NS_ENUM(NSInteger, BTPayPalDriverErrorType) {

    BTPayPalDriverErrorTypeUnknown = 0,

    /// PayPal is disabled in configuration
    BTPayPalDriverErrorTypeDisabled,

    /// App switch is not configured appropriately. You must specify a
    /// valid returnURLScheme via Braintree before attempting an app switch.
    BTPayPalDriverErrorTypeIntegrationReturnURLScheme,

    /// UIApplication failed to switch despite it being available.
    /// `[UIApplication openURL:]` returned `NO` when `YES` was expected.
    BTPayPalDriverErrorTypeAppSwitchFailed,

    /// Invalid configuration, e.g. bad CFBundleDisplayName
    BTPayPalDriverErrorTypeInvalidConfiguration,
};

BT_ASSUME_NONNULL_BEGIN

@protocol BTPayPalDriverDelegate;

@interface BTPayPalDriver : NSObject

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient returnURLScheme:(NSString *)returnURLScheme;

@property (nonatomic, copy) NSString *clientToken DEPRECATED_MSG_ATTRIBUTE("Delete me as soon as possible. BTPayPalDriver only requires a client token due to Browser-Switch requiring a client token.");

- (void)authorizeAccountWithCompletion:(void (^)(__BT_NULLABLE BTTokenizedPayPalAccount *tokenizedPayPalAccount, __BT_NULLABLE NSError *error))completionBlock;

- (void)authorizeAccountWithAdditionalScopes:(NSSet<NSString *> *)additionalScopes
                                  completion:(void (^)(__BT_NULLABLE BTTokenizedPayPalAccount *tokenizedPayPalAccount, __BT_NULLABLE NSError *error))completionBlock;

- (void)checkoutWithCheckoutRequest:(BTPayPalCheckoutRequest *)checkoutRequest
                         completion:(void (^)(__BT_NULLABLE BTTokenizedPayPalCheckout *tokenizedPayPalCheckout, __BT_NULLABLE NSError *error))completionBlock;

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

