#import <Foundation/Foundation.h>
#import "BTPaymentMethod.h"

/// Delegate protocol for receiving messages about state changes to an app switch handler
@protocol BTAppSwitchHandlerDelegate <NSObject>

@optional

/// This message is sent immediately before app switch will be initiated.
///
/// @param appSwitchHandler
- (void)appSwitchHandlerWillAppSwitch:(id)appSwitchHandler;

/// This message is sent when the user has authorized payment, and the payment method
/// is about to be created.
///
/// @param appSwitchHandler
- (void)appSwitchHandlerWillCreatePaymentMethod:(id)appSwitchHandler;

@required

/// This message is sent when a payment method has been authorized and is available.
///
/// @param appSwitchHandler The requesting handler
/// @param paymentMethod The resulting payment method
- (void)appSwitchHandler:(id)appSwitchHandler didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod;

/// This message is sent when the payment method could not be created.
///
/// @param appSwitchHandler The handler that
- (void)appSwitchHandler:(id)appSwitchHandler didFailWithError:(NSError *)error;

/// This message is sent when the payment was cancelled.
///
/// @param appSwitchHandler The cancelled handler
- (void)appSwitchHandlerDidCancel:(id)appSwitchHandler;

@end