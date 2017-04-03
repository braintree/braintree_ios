#import <UIKit/UIKit.h>

#import "Braintree-API.h"

@protocol BTPayPalViewControllerDelegate;

/// A View Controller that encapsulates the PayPal user authentication and consent flows
/// in order to obtain a Braintree payment method nonce.
///
/// In the simple case, you should use BTPayPalButton, which will initialize and manage its own
/// BTPayPalViewController instance. This class is only necessary if you want to implement
/// your own button to trigger the Braintree PayPal flow.
@interface BTPayPalViewController : UIViewController

/// A delegate that should be notified as the PayPal consent flow changes state.
@property (nonatomic, weak) id<BTPayPalViewControllerDelegate> delegate;

/// Your initialized Braintree client.
///
/// @see Braintree-API-iOS
@property (nonatomic, strong) BTClient *client;

/// Initialize a `BTPayPalViewController` with a preset BTClient
///
/// @param client Client to retain as the new instance's client
/// @see client
///
/// @return A new BTPayPalViewController instance
- (instancetype)initWithClient:(BTClient *)client;

@end

/// Delegate protocol for receiving results from a BTPayPalViewController
@protocol BTPayPalViewControllerDelegate <NSObject>

@optional

/// The user has completed his or her interaction with the PayPal UI. The View Controller will now attempt
/// to create a PayPal account payment method with a nonce.
///
/// You can implement this in order to dismiss the PayPal View Controller before a definitive
/// success (i.e. nonce) or error (i.e. failure to create a nonce) occurs.
///
/// @param viewController The `BTPayPalViewController` that will create the nonce.
- (void)payPalViewControllerWillCreatePayPalPaymentMethod:(BTPayPalViewController *)viewController;

/// The PayPal View Controller will send this message when the PayPal consent flow is complete and a payment method
/// has been created. You can send its nonce value to your server for creating a transaction, subscription, etc.
///
/// @param viewController The `BTPayPalViewController` that did create the nonce
/// @param payPalPaymentMethod PayPal account payment method that contains a nonce
- (void)payPalViewController:(BTPayPalViewController *)viewController didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)payPalPaymentMethod;

/// The PayPal View Controller will send this message when a nonce could not be created.
///
/// @param viewController The `BTPayPalViewController` that failed
/// @param error The `BTClient` error that caused the failure.
- (void)payPalViewController:(BTPayPalViewController *)viewController didFailWithError:(NSError *)error;

/// The user requested to cancel the PayPal consent flow.
///
/// @param viewController The `BTPayPalViewController` that was cancelled
- (void)payPalViewControllerDidCancel:(BTPayPalViewController *)viewController;

@end
