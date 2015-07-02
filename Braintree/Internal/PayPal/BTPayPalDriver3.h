@import Foundation;

#import "BTPayPalPaymentMethod.h"
#import "BTPayPalCheckout.h"
#import "BTNullability.h"
#import "BTConfiguration.h"
#import "BTAPIClient.h"

BT_ASSUME_NONNULL_BEGIN

@protocol BTPayPalDriver3Delegate;




/// The BTPayPalDriver3 enables you to obtain permission to charge your customers' PayPal accounts via app switch to the PayPal app and the browser.
///
/// @note To make PayPal available, you must ensure that PayPal is enabled in your Braintree control panel. See our [online documentation](https://developers.braintreepayments.com/ios+ruby/guides/paypal) for details.
///
/// This class supports two basic use-cases: Vault and Checkout. Each of these involves variations on the user experience as well as variations on the capabilities granted to you by this authorization.
///
/// The *Vault* option uses PayPal's future payments authorization, which allows your merchant account to charge this customer arbitrary amounts for a long period of time into the future (unless the user manually revokes this permission in their PayPal control panel.) This authorization flow includes an screen with legal language that directs the user to agree to the terms of Future Payments. Unfortunately, it is not currently possible to collect shipping information in the Vault flow.
///
/// The *Checkout* option creates a one-time use PayPal payment on your behalf. As a result, you must specify the checkout details up-front, so that they can be shown to the user during the PayPal flow. With this flow, you must specify the estimated transaction amount, and you can collect shipping details. While this flow omits the Future Payments agreement, the resulting payment method cannot be stored in the vault. It is only possible to create one Braintree transaction with this form of user approval.
///
/// Both of these flows are available to all users on any iOS device. If the PayPal app is installed on the device, the PayPal login flow will take place there via an app switch. Otherwise, PayPal login takes place in the Safari browser.
///
/// Regardless of the type or target, all of these user experiences take full advantage of One Touch. This means that users may bypass the username/password entry screen when they are already logged in.
///
/// Upon successful completion, you will receive a BTPayPalPaymentMethod, which includes user-facing details and a payment method nonce, which you must pass to your server in order to create a transaction or save the authorization in the Braintree vault (not possible with Checkout).
///
/// ## User Experience Details
///
/// To keep your UI in sync during app switch authentication, you may set a delegate, which will receive notifications as the PayPal driver progresses through the various steps necessary for user authentication.
///
/// ## App Switching Details
///
/// This class will handle switching out of your app to the PayPal app or the browser (including the call to `-[UIApplication openURL:]`).
///
/// You must pass in a URL scheme that will be used to return to this app.
///
/// Your URL scheme must be registered as a URL Type in your info.plist, and it must start with your app's bundle identifier.
@interface BTPayPalDriver3 : NSObject

/// Initializes a PayPal app switch
///
/// Note: BTPayPalDriver3 will fail to initialize if PayPal is not enabled in the control panel or the app is not set up correctly for app switch.
///
/// @param client An instance of BTClient for communicating with Braintree
/// @param returnURLScheme Your app's URL Scheme
///
/// @return An instance that is ready to perform authorization or checkout; or nil if the client or URL Scheme are invalid
- (nullable instancetype)initWithConfiguration:(BTConfiguration *)configuration NS_DESIGNATED_INITIALIZER;


#pragma mark - PayPal Login

/// Authorize a PayPal user for saving their account in the Vault via app switch to the PayPal App or the browser.
///
/// On success, you will receive a paymentMethod, on failure, an error, on user cancelation, you will receive nil for both parameters.
///
/// Note that during the app switch authorization, the user may switch back to your app manually. In this case, the caller will not receive a cancelation via the completionBlock. Rather, it is the caller's responsibility to observe `UIApplicationDidBecomeActiveNotification` and `UIApplicationWillResignActiveNotification` using `NSNotificationCenter` if necessary.
///
/// @param completionBlock This completion will be invoked exactly once when authorization is complete or an error occurs.






/// Authorize a PayPal user for saving their account in the Vault via app switch to the PayPal App or the browser with
/// additional scopes (Ex: 'address').
///
/// On success, you will receive a paymentMethod, on failure, an error, on user cancelation, you will receive nil for both parameters.
///
/// Note that during the app switch authorization, the user may switch back to your app manually. In this case, the caller will not receive a cancelation via the completionBlock. Rather, it is the caller's responsibility to observe `UIApplicationDidBecomeActiveNotification` and `UIApplicationWillResignActiveNotification` using `NSNotificationCenter` if necessary.
/// @param additionalScopes Set of requested scope-values.
///        Available scope-values are listed at https://developer.paypal.com/webapps/developer/docs/integration/direct/identity/attributes/
/// @param completionBlock This completion will be invoked exactly once when authorization is complete or an error occurs.





/// Checkout with PayPal for creating a single-use PayPal payment method nonce.
///
/// You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your server when this method completes without any additional user interaction.
///
/// @note This method is mutually exclusive with startAuthorizationWithCompletion:. In either case, you need to create a Braintree transaction from your server in order to actually move money!
///
/// @param completionBlock This completion will be invoked when authorization is complete.



@end



BT_ASSUME_NONNULL_END
