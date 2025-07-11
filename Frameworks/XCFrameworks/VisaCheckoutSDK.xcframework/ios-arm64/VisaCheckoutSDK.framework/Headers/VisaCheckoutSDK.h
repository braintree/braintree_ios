/**
 Copyright © 2018 Visa. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "VisaProfile.h"
#import "VisaPurchaseInfo.h"
#import "VisaCheckoutButton.h"

typedef NS_ENUM(NSInteger, VisaCheckoutConfigStatus);

/**
 The `VisaCheckoutSDK` class is primarily used for configuring a manual checkout session
 for invoking the Visa Checkout SDK directly.
*/
@interface VisaCheckoutSDK : NSObject

/**
 Call this method to preload the Visa Checkout button so that it is visible as soon as a returning user gets to the checkout screen.
 */
+ (void)configure;

/// :nodoc:
-(instancetype _Nonnull) __unavailable init;

/**
 Call this method to configure the Visa Checkout SDK using a `VisaProfile` object with customizable
 options.

 @param profile The profile object that holds all of your profile customizations options.
 @param result The result of configuring the Visa Checkout SDK. This result will report
 any errors if there were issues initializing. It will also report a successful configuration,
 at which time the VisaCheckoutButton will be ready to interact with.
 */
+ (void)configureWithProfile:(VisaProfile *_Nonnull)profile result:(void (^ _Nullable)(VisaCheckoutConfigStatus))result
DEPRECATED_MSG_ATTRIBUTE("Please use VisaCheckoutButton's onCheckout(profile:purchaseInfo:presenting:onReady:onButtonTapped:completion:) instead. \
Or in the case of manually launching checkout without using VisaCheckoutButton, use VisaCheckoutSDK's \
configureManualCheckoutSession(profile:purchaseInfo:presenting:onReady:result:)")
NS_SWIFT_NAME(configure(profile:result:));

/**
 Call this method to configure the Visa Checkout SDK using the basic information
 required to launch the Visa Checkout user interface.

 @param environment The context with which Visa Checkout accounts are managed. For instance,
 `sandbox` will not have actual Visa Checkout accounts and it is safe to use this environment
 for testing the Visa Checkout integration.
 @param apiKey The API Key string given associated with your Visa Merchant account.
 This key will be dependent on which `VisaEnvironment` you are connecting to. For instance, you
 will have one API Key for the `VisaEnvironmentSandbox` and a different API Key for the `VisaEnvironmentProduction`.
 @param profileName The profile name associated with your Visa Merchant account.
 @param result The result of configuring the Visa Checkout SDK. This result will report
 any errors if there were issues initializing. It will also report a successful configuration,
 at which time the VisaCheckoutButton will be ready to interact with.
*/
+ (void)configureWithEnvironment:(VisaEnvironment)environment apiKey:(NSString * _Nonnull)apiKey profileName:(NSString * _Nullable)profileName result:(void (^ _Nullable)(VisaCheckoutConfigStatus))result
DEPRECATED_MSG_ATTRIBUTE("Please use VisaCheckoutButton's `onCheckout(profile:purchaseInfo:presenting:onReady:onButtonTapped:completion:)` instead. \
Or in the case of manually launching checkout without using VisaCheckoutButton, use VisaCheckoutSDK's \
`configureManualCheckoutSession(profile:purchaseInfo:presenting:onReady:result:)`")
NS_SWIFT_NAME(configure(environment:apiKey:profileName:result:));

/**
 A convenience method to manually launch the Visa Checkout user interface with the basic
 information needed to complete a transaction. If the Visa Checkout SDK is configured
 properly, this will immediately present the Visa Checkout user interface to the user.
 
 - Parameter total: The total amount of the purchase your customer is attempting to pay.
 - Parameter currency: The `VisaCurrency` used for this purchase amount.
 - Parameter completion: A completion handler that is called when the `VisaCheckoutSDK` is finished and
 has return context back to your app.
 */
+ (void)checkoutWithTotal:(VisaCurrencyAmount * _Nonnull)total
                 currency:(VisaCurrency)currency
               completion:(VisaCheckoutResultHandler _Nonnull)completion
DEPRECATED_MSG_ATTRIBUTE("Please use `configureManualCheckoutSession(profile:purchaseInfo:presenting:onReady:result:)` instead")
NS_SWIFT_NAME(checkout(total:currency:completion:));

/**
 A method to manually launch the Visa Checkout user interface with the detailed
 `VisaPurchaseInfo` used to complete a transaction. If the Visa Checkout SDK is configured
 properly, this will immediately present the Visa Checkout user interface to the user.
 
 - Parameter purchaseInfo:The purchase information with various settings used to customize the Checkout experience.
 - Parameter completion: A completion handler that is called when the `VisaCheckoutSDK` is finished and
 has return context back to your app.
 */
+ (void)checkoutWithPurchaseInfo:(VisaPurchaseInfo * _Nonnull)purchaseInfo
                      completion:(VisaCheckoutResultHandler _Nonnull)completion
DEPRECATED_MSG_ATTRIBUTE("Please use `configureManualCheckoutSession(profile:purchaseInfo:presenting:onReady:result:)` instead")
NS_SWIFT_NAME(checkout(purchaseInfo:completion:));

/** A value indicating whether the Visa Checkout SDK is configured and ready to launch,
 whether launched manually or through a VisaCheckoutButton tap. The VisaCheckoutButton will be
 enabled when this property is true (and disabled when this property is false).
 */
+ (BOOL)isReady DEPRECATED_MSG_ATTRIBUTE("Method is no longer supported");

/**
 Used to configure Visa Checkout when manually invoking the SDK without using `VisaCheckoutButton`.
 Provide the onReady callback for storing a `LaunchHandle` which can be invoked later when a user
 taps your custom button.
 */
+(void)configureManualCheckoutSessionWithProfile:(VisaProfile * _Nonnull)profile
                                    purchaseInfo:(VisaPurchaseInfo * _Nonnull)purchaseInfo
                        presentingViewController:(UIViewController * _Nonnull)viewController
                                         onReady:(ManualCheckoutReadyHandler _Nonnull)onReady
                                          result:(VisaCheckoutResultHandler _Nonnull)result
NS_SWIFT_NAME(configureManualCheckoutSession(profile:purchaseInfo:presenting:onReady:result:));

/** Call this method to update payment information after original information passed to Visa has changed.
 @param parameters A dictionary of key/value pairs that should include apiKey, callId, eventType,
 some amount key e.g. ‘total’, and currencyCode.
*/
+ (void)updatePaymentInfoWithParameters:(NSDictionary<NSString *, id> * _Nonnull)parameters DEPRECATED_MSG_ATTRIBUTE("Please use `updatePaymentInfo(purchaseInfo:completion:)` instead")
NS_SWIFT_NAME(updatePaymentInfo(parameters:));

/** Call this method to update payment information after original information passed to Visa has changed.
 @param purchaseInfo A `VisaPurchaseInfo` object containing the updated values. The only values currently supported are
  `VisaPurchaseInfo.total`, `VisaPurchaseInfo.subtotal`, and `VisaPurchaseInfo.currency`.
 @param completion A completion handler for providing the results and possible error from the update payment info call. When `success` is false, it could just mean an unknown issue or that the submitted `purchaseInfo` is no different than what was submitted previously.
*/
+ (void)updatePaymentInfo:(VisaPurchaseInfo * _Nonnull)purchaseInfo
           withCompletion:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completion
NS_SWIFT_NAME(updatePaymentInfo(purchaseInfo:completion:));

/** Use for campaign tracking promotions.
 Should be set in the application:openURL:options: UIApplicationDelegate method.
 */
@property (nonatomic, class) NSURL * _Nullable marketingUrl;

@end

/// :nodoc:
typedef NS_ENUM(NSInteger, VisaCheckoutConfigStatus) {
    /** You have attempted to run the Visa Checkout SDK in debug mode
     while simultaneously configuring using VisaEnvironmentProduction
     as the `environment` value.
     */
    VisaCheckoutConfigStatusDebugModeNotSupported,
    /** An internal error occurred. This is unexpected behavior and should be
     reported to a Visa Checkout team member.
     */
    VisaCheckoutConfigStatusInternalError,
    /** You have supplied an incorrect API Key value for the apiKey
     property. Be sure to obtain a valid API Key from your developer
     account and also remember to use the correct API Key for the correct
     environment.
     For example, you will have at least 2 API Keys. One
     for the VisaEnvironmentSandbox type and one for the VisaEnvironmentProduction
     type. Be sure you are using the correct one and also be sure
     you have copied the value correctly.
     */
    VisaCheckoutConfigStatusInvalidAPIKey,
    /** You have provided an incorrect profileName value. If you wish
     to use the default profile on your account, you can pass nil.
     */
    VisaCheckoutConfigStatusInvalidProfileName,
    /** There was an unexpected network failure. This can either be due
     to an inconsistent internet connection or from an invalid
     parameter being used while configuring VisaCheckoutSDK.
     */
    VisaCheckoutConfigStatusNetworkFailure,
    /** Visa Checkout does not support landscape-only iPhone apps.
     The app must also support portrait orientation.
     */
    VisaCheckoutConfigStatusNoCommonSupportedOrientations,
    /** You are using an unsupported version of the Visa Checkout SDK.
     You must upgrade to a newer version in order to use the SDK.
     */
    VisaCheckoutConfigStatusSdkVersionDeprecation,
    /** Config is complete with no errors.
     */
    VisaCheckoutConfigStatusSuccess
} NS_SWIFT_NAME(CheckoutConfigStatus);

