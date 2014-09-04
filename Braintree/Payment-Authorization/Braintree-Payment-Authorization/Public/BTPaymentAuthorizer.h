@import UIKit;
@import Foundation;

#import "BTPaymentAuthorizationErrors.h"

@class BTClient, BTPaymentMethod;
@protocol BTPaymentAuthorizerDelegate;

typedef NS_ENUM(NSInteger, BTPaymentAuthorizationType) {
    BTPaymentAuthorizationTypePayPal = 0,
    BTPaymentAuthorizationTypeVenmo
};


typedef NS_OPTIONS(NSInteger, BTPaymentAuthorizationOptions) {
    BTPaymentAuthorizationOptionMechanismAppSwitch = 1 << 0,
    BTPaymentAuthorizationOptionMechanismViewController = 1 << 1,
    BTPaymentAuthorizationOptionMechanismAny = BTPaymentAuthorizationOptionMechanismViewController | BTPaymentAuthorizationOptionMechanismAppSwitch
};

/// TODO: Description
@interface BTPaymentAuthorizer : NSObject

- (instancetype)initWithClient:(BTClient *)client;

- (id)init __attribute__((unavailable("Please use initWithClient:")));

///  Perform authorization with custom options
///
///  @param type    The type of authorization to perform
///  @param options Authorization options
- (void)authorize:(BTPaymentAuthorizationType)type options:(BTPaymentAuthorizationOptions)options;

///  Perform authorization
///
///  Shorthand for `authorize:type options:BTPaymentAuthorizationOptionMechanismAny`
///
///  @see authorize:options:
///
///  @param type    The type of authorization to perform
- (void)authorize:(BTPaymentAuthorizationType)type;

///  BTClient to use in authorizing
@property (nonatomic, strong) BTClient *client;

///  Delegate to receive messages during payment authorization process
@property (nonatomic, weak) id<BTPaymentAuthorizerDelegate> delegate;

///  The set of available authorization types, represented as NSValues
///  of BTPaymentAuthorizationType.
- (BOOL)supportsAuthorizationType:(BTPaymentAuthorizationType)type;

@end

/// Protocol for receiving authorization lifecycle messages from a payment authorizer
@protocol BTPaymentAuthorizerDelegate <NSObject>

///  The payment authorizer requires presentation of a view controller in order to
///  obtain user payment authorization.
///
///  @param sender         The payment authorizer
///  @param viewController The view controller to be presented
///
///  @return Whether the view controller was presented.
- (void)paymentAuthorizer:(id)sender requestsAuthorizationWithViewController:(UIViewController *)viewController;

///  The payment authorizer has completed and requires dismissal of a view controller.
///
///  @param sender         The payment authorizer
///  @param viewController The view controller to be presented
///
///  @return Whether the view controller was dismissed.
- (void)paymentAuthorizer:(id)sender requestsDismissalOfAuthorizationViewController:(UIViewController *)viewController;

///  The payment authorizer will perform an app switch in order to obtain user
///  payment authorization.
///
///  @note REPHRASE Reenable the button in case things fail
///  @param sender The payment authorizer
- (void)paymentAuthorizerWillRequestAuthorizationWithAppSwitch:(id)sender;

///  The payment authorizer, having obtained user payment details and/or user
///  authorization, will now process the results.
///
///  @note This typically indicates asynchronous network activity. When you receive this message, your UI should indicate this activity.
///  @note REPHRASE Disable the button in case things fail
///  @param sender The payment authorizer
- (void)paymentAuthorizerWillProcessAuthorizationResponse:(id)sender;

///  The payment authorizer has cancelled.
///
///  @param sender The payment authorizer
- (void)paymentAuthorizerDidCancel:(id)sender;

///  The payment authorizer received authorization, which it then successfully
///  used to create a payment method.
///
///  @param sender        The payment authorizer
///  @param paymentMethod The resulting payment method
- (void)paymentAuthorizer:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod;

///  The payment authorizer failed to create a payment method.
///
///  @param sender The payment authorizer
///  @param error  An error that characterizes the failure
- (void)paymentAuthorizer:(id)sender didFailWithError:(NSError *)error;

@end