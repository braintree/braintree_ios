#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTTokenizedPayPalAccount.h"
#import "BTPayPalCheckoutRequest.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const BTPayPalDriverErrorDomain;

typedef NS_ENUM(NSInteger, BTPayPalDriverErrorType) {

    BTPayPalDriverErrorTypeUnknown = 0,

    /// PayPal is disabled in configuration
    BTPayPalDriverErrorTypeDisabled,

    /// App switch is not configured appropriately. You must specify a
    /// valid returnURLScheme via BTAppSwitch before attempting an app switch.
    BTPayPalDriverErrorTypeIntegrationReturnURLScheme,

    /// UIApplication failed to switch despite it being available.
    /// `[UIApplication openURL:]` returned `NO` when `YES` was expected.
    BTPayPalDriverErrorTypeAppSwitchFailed,

    /// Invalid configuration, e.g. bad CFBundleDisplayName
    BTPayPalDriverErrorTypeInvalidConfiguration,

    /// Invalid request, e.g. missing checkout request
    BTPayPalDriverErrorTypeInvalidRequest,
    
    /// Braintree SDK is integrated incorrectly
    BTPayPalDriverErrorTypeIntegration,
};

/// BTPayPalDriver enables you to obtain permission to charge your customers' PayPal accounts via app
/// switch to the PayPal app and the browser.
///
/// @note To make PayPal available, you must ensure that PayPal is enabled in your Braintree control panel.
/// See our [online documentation](https://developers.braintreepayments.com/ios+ruby/guides/paypal) for
/// details.
///
/// This class supports two basic use-cases: Vault and Checkout. Each of these involves variations on the
/// user experience as well as variations on the capabilities granted to you by this authorization.
///
/// The *Vault* option uses PayPal's future payments authorization, which allows your merchant account to
//// charge this customer arbitrary amounts for a long period of time into the future (unless the user
/// manually revokes this permission in their PayPal control panel.) This authorization flow includes
/// a screen with legal language that directs the user to agree to the terms of Future Payments.
/// Unfortunately, it is not currently possible to collect shipping information in the Vault flow.
///
/// The *Checkout* option creates a one-time use PayPal payment on your behalf. As a result, you must
/// specify the checkout details up-front, so that they can be shown to the user during the PayPal flow.
/// With this flow, you must specify the estimated transaction amount, and you can collect shipping
/// details. While this flow omits the Future Payments agreement, the resulting payment method cannot be
/// stored in the vault. It is only possible to create one Braintree transaction with this form of user
/// approval.
///
/// Both of these flows are available to all users on any iOS device. If the PayPal app is installed on the
/// device, the PayPal login flow will take place there via an app switch. Otherwise, PayPal login takes
/// place in the Safari browser.
///
/// Regardless of the type or target, all of these user experiences take full advantage of One Touch. This
/// means that users may bypass the username/password entry screen when they are already logged in.
///
/// Upon successful completion, you will receive a `BTTokenizedPayPalAccount` or `BTTokenizedPayPalAccount`,
/// which includes user-facing details and a payment method nonce, which you must pass to your server in
/// order to create a transaction or save the authorization in the Braintree vault (not possible with
/// Checkout).
///
/// ## User Experience Details
///
/// To keep your UI in sync during app switch authentication, you may set a delegate, which will receive
/// notifications as the PayPal driver progresses through the various steps necessary for user
/// authentication.
///
/// ## App Switching Details
///
/// This class will handle switching out of your app to the PayPal app or the browser (including the call to
/// `-[UIApplication openURL:]`).
///

@interface BTPayPalDriver : NSObject <BTAppSwitchHandler>


/// Initialize a new PayPal driver instance.
///
/// @param apiClient The API client
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;


- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

/// Authorize a PayPal user for saving their account in the Vault via app switch to the PayPal App or the browser.
///
/// @note During the app switch authorization, the user may switch back to your app manually. In this case, the caller
/// will not receive a cancellation via the completionBlock. Rather, it is the caller's responsibility to observe
/// `UIApplicationDidBecomeActiveNotification` and `UIApplicationWillResignActiveNotification` using `NSNotificationCenter`
/// if necessary.
///
/// @param completionBlock This completion will be invoked exactly once when authorization is complete or an error occurs.
/// On success, you will receive an instance of `BTTokenizedPayPalAccount`; on failure, an error; on user cancellation,
/// you will receive `nil` for both parameters.
- (void)authorizeAccountWithCompletion:(void (^)(BTTokenizedPayPalAccount * _Nullable tokenizedPayPalAccount, NSError * _Nullable error))completionBlock;


/// Authorize a PayPal user for saving their account in the Vault via app switch to the PayPal App or the browser with
/// additional scopes (e.g. address).
///
/// @note During the app switch authorization, the user may switch back to your app manually. In this case, the caller
/// will not receive a cancellation via the completionBlock. Rather, it is the caller's responsibility to observe
/// `UIApplicationDidBecomeActiveNotification` and `UIApplicationWillResignActiveNotification` using `NSNotificationCenter`
/// if necessary.
///
/// @param additionalScopes An `NSSet` of requested scope-values as `NSString`s. Available scope-values are listed at
/// https://developer.paypal.com/webapps/developer/docs/integration/direct/identity/attributes/
/// @param completionBlock This completion will be invoked exactly once when authorization is complete or an error occurs.
/// On success, you will receive an instance of `BTTokenizedPayPalAccount`; on failure, an error; on user cancellation,
/// you will receive `nil` for both parameters.
- (void)authorizeAccountWithAdditionalScopes:(NSSet<NSString *> *)additionalScopes
                                  completion:(void (^)(BTTokenizedPayPalAccount * _Nullable tokenizedPayPalAccount, NSError * _Nullable error))completionBlock;


/// Check out with PayPal to create a single-use PayPal payment method nonce.
///
/// You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
/// server when this method completes without any additional user interaction.
///
/// @note This method is mutually exclusive with `authorizeAccountWithCompletion:`. In both cases, you need to create a
/// Braintree transaction from your server in order to actually move money!
///
/// @param completionBlock This completion will be invoked exactly once when checkout is complete or an error occurs.
/// On success, you will receive an instance of `BTTokenizedPayPalAccount`; on failure, an error; on user cancellation,
/// you will receive `nil` for both parameters.
- (void)checkoutWithCheckoutRequest:(BTPayPalCheckoutRequest *)checkoutRequest
                         completion:(void (^)(BTTokenizedPayPalAccount * _Nullable tokenizedPayPalCheckout, NSError * _Nullable error))completionBlock;

/// Check out with PayPal to create a Billing Agreement PayPal payment method nonce.
///
/// You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
/// server when this method completes without any additional user interaction.
///
/// @note This method is mutually exclusive with `authorizeAccountWithCompletion:`. In both cases, you need to create a
/// Braintree transaction from your server in order to actually move money!
///
/// @param completionBlock This completion will be invoked exactly once when checkout is complete or an error occurs.
/// On success, you will receive an instance of `BTTokenizedPayPalAccount`; on failure, an error; on user cancellation,
/// you will receive `nil` for both parameters.
- (void)billingAgreementWithCheckoutRequest:(BTPayPalCheckoutRequest *)checkoutRequest
                         completion:(void (^)(BTTokenizedPayPalAccount * _Nullable tokenizedPayPalCheckout, NSError * _Nullable error))completionBlock;


#pragma mark - Delegate

/// An optional delegate for receiving notifications about the lifecycle of a PayPal app switch for updating your UI
@property (nonatomic, weak, nullable) id<BTAppSwitchDelegate> delegate;

/// A required delegate to control the presentation and dismissal of view controllers
@property (nonatomic, weak, nullable) id<BTViewControllerPresentingDelegate> viewControllerPresentingDelegate;

@end

NS_ASSUME_NONNULL_END
