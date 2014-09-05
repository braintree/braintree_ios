@import UIKit;
@import Foundation;

#import "BTPaymentAuthorizationErrors.h"
#import "BTClient.h"
#import "BTPaymentMethod.h"

@protocol BTPaymentAuthorizerDelegate;

/// Type of payment authorization to perform
typedef NS_ENUM(NSInteger, BTPaymentAuthorizationType) {
    /// Authorize via PayPal
    BTPaymentAuthorizationTypePayPal = 0,

    /// Authorize via Venmo
    BTPaymentAuthorizationTypeVenmo
};

/// Options for payment authorization
typedef NS_OPTIONS(NSInteger, BTPaymentAuthorizationOptions) {

    /// Enable app-switch authorization if available.
    /// This is the highest priority mechanism option.
    BTPaymentAuthorizationOptionMechanismAppSwitch = 1 << 0,

    /// Authorize via in-app view controller presentation, if available for authorization type.
    /// BTPaymentAuthorizationOptionMechanismAppSwitch takes precedence.
    BTPaymentAuthorizationOptionMechanismViewController = 1 << 1,

    /// Authorize via any available mechanism
    BTPaymentAuthorizationOptionMechanismAny = BTPaymentAuthorizationOptionMechanismViewController | BTPaymentAuthorizationOptionMechanismAppSwitch
};

/// The BTPaymentAuthorizer enables you to collect payment information from the user.
///
/// This class abstracts the various payment payment providers and authorization
/// techniques. After initialization, you must set a client and delegate before
/// calling `authorize:`. The authorization may request (via the delegate) that
/// you present a view controller, e.g., a PayPal login screen. authorize: may also
/// initiate an app switch if available. (See +[Braintree setReturnURLScheme:] and +[Braintree handleOpenURL:sourceApplication:])
@interface BTPaymentAuthorizer : NSObject

- (instancetype)initWithClient:(BTClient *)client;

- (id)init __attribute__((unavailable("Please use initWithClient:")));

/// BTClient to use during authorization
@property (nonatomic, strong) BTClient *client;

/// Delegate to receive messages during payment authorization process
@property (nonatomic, weak) id<BTPaymentAuthorizerDelegate> delegate;

/// Initate authorization
///
/// Shorthand for `[authorize:type options:BTPaymentAuthorizationOptionMechanismAny]`
///
/// The delegate's paymentAuthorizer:didFailWithError: will be invoked if
/// authorization cannot be initiated.
///
/// @see authorize:options:
///
/// @param type    The type of authorization to perform
- (void)authorize:(BTPaymentAuthorizationType)type;

/// Initiate authorization with custom options
///
/// The delegate's paymentAuthorizer:didFailWithError: will be invoked if
/// authorization cannot be initiated.
///
/// @param type    The type of authorization to perform
/// @param options Authorization options
- (void)authorize:(BTPaymentAuthorizationType)type options:(BTPaymentAuthorizationOptions)options;

/// The set of all available authorization types, represented as NSValues
/// boxing BTPaymentAuthorizationType.
- (BOOL)supportsAuthorizationType:(BTPaymentAuthorizationType)type;

@end

/// Protocol for receiving authorization lifecycle messages from a payment authorizer
@protocol BTPaymentAuthorizerDelegate <NSObject>

/// The payment authorizer requires presentation of a view controller in order to
/// obtain user payment authorization.
///
/// Your implementation should ensure that this viewController is presented, e.g. via
/// `presentViewController:animated:completion:`
///
/// @param sender         The payment authorizer
/// @param viewController The view controller to be presented
- (void)paymentAuthorizer:(id)sender requestsAuthorizationWithViewController:(UIViewController *)viewController;

/// The payment authorizer requires dismissal of a view controller.
///
/// Your implementation should ensure that this viewController is dismissed, e.g. via
/// `dismissViewControllerAnimated:completion:`
///
/// @param sender         The payment authorizer
/// @param viewController The view controller to be presented
- (void)paymentAuthorizer:(id)sender requestsDismissalOfAuthorizationViewController:(UIViewController *)viewController;

/// The payment authorizer will perform an app switch in order to obtain user
/// payment authorization.
///
/// Your implementation of this method should set your app to the state
/// it should be in if the user manually app-switches back to your app.
/// For example, re-enable any controls that are disabled.
///
/// @param sender The payment authorizer
- (void)paymentAuthorizerWillRequestAuthorizationWithAppSwitch:(id)sender;

/// The payment authorizer, having obtained user payment details and/or user
/// authorization, will now process the results.
///
/// This typically indicates asynchronous network activity.
/// When you receive this message, your UI should indicate activity.
///
/// @param sender The payment authorizer
- (void)paymentAuthorizerWillProcessAuthorizationResponse:(id)sender;

/// The payment authorizer has cancelled.
///
/// @param sender The payment authorizer
- (void)paymentAuthorizerDidCancel:(id)sender;

/// The payment authorizer received authorization, which it then successfully
/// used to create a payment method.
///
/// Typically an implementation will convey this paymentMethod to your own server
/// for further use.
///
/// @param sender        The payment authorizer
/// @param paymentMethod The resulting payment method
- (void)paymentAuthorizer:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod;

/// The payment authorizer failed to create a payment method.
///
/// A failure may occur at any point during payment authorization, such as when:
/// - Payment authorization is initiated with bad configuration
/// - An authorization provider (e.g. Venmo or PayPal) encounters an error
/// - A network or gateway error occurs
///
/// @param sender The payment authorizer
/// @param error  An error that characterizes the failure
- (void)paymentAuthorizer:(id)sender didFailWithError:(NSError *)error;

@end