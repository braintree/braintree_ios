#import "BTPaymentRequest.h"
#import "BTUIThemedView.h"
#import <UIKit/UIKit.h>

@protocol BTAppSwitchDelegate, BTViewControllerPresentingDelegate;
@class BTAPIClient, BTPaymentMethodNonce;

NS_ASSUME_NONNULL_BEGIN

@interface BTPaymentButton : BTUIThemedView

/// Initialize a BTPaymentButton.
///
/// @param apiClient A BTAPIClient used for communicating with Braintree servers. Required.
/// @param completion A completion block. Required.
///
/// @return A new BTPaymentButton.
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient completion:(void(^)(BTPaymentMethodNonce *paymentMethodNonce, NSError *error))completion;

/// The BTAPIClient used for communicating with Braintree servers.
///
/// This property is exposed to enable the use of other UIView initializers, e.g.
/// when using Storyboards.
@property (nonatomic, strong) BTAPIClient *apiClient;

/// The BTPaymentRequest that customizes the payment experience.
@property (nonatomic, strong) BTPaymentRequest *paymentRequest;

/// The completion block to handle the result of a payment authorization flow.
///
/// This property is exposed to enable the use of other UIView initializers, e.g.
/// when using Storyboards.
@property (nonatomic, copy) void(^completion)(BTPaymentMethodNonce *paymentMethodNonce, NSError *error);

/// Set of payment options as strings, e.g. `@"PayPal"`, `@"Venmo"`. By default, this is configured
/// to the set of payment options that have been included in the client-side app integration,
/// e.g. via frameworks.
///
/// Setting this property will force the button to reload.
@property (nonatomic, strong) NSOrderedSet *enabledPaymentOptions;

/// Configuration from a BTAPIClient. By default, BTPaymentButton will display all payment options
/// included in the client-side app integration. Provide configuration in order to hide payment
/// options that are not enabled in the server-side Braintree Control Panel.
///
/// Setting this property will force the button to reload.
@property (nonatomic, strong) BTConfiguration *configuration;

/// Optional delegate for receiving payment lifecycle messages from a payment option
/// that may initiate an app or browser switch to authorize payments.
@property (nonatomic, weak, nullable) id <BTAppSwitchDelegate> appSwitchDelegate;

/// Optional delegate for receiving payment lifecycle messages from a payment driver
/// that requires presentation of a view controller to authorize a payment.
///
/// Required by PayPal.
@property (nonatomic, weak, nullable) id <BTViewControllerPresentingDelegate> viewControllerPresentingDelegate;

/// Indicates whether any payment options available.
@property (nonatomic, readonly) BOOL hasAvailablePaymentMethod;

@end

NS_ASSUME_NONNULL_END
