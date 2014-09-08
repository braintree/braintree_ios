#import <Foundation/Foundation.h>

#import "BTPaymentMethod.h"

@protocol BTAppSwitching;

/// Delegate protocol for receiving messages about state changes to an app switch handler
@protocol BTAppSwitchingDelegate <NSObject>

@optional

/// This message is sent when the user has authorized payment, and the payment method
/// is about to be created.
- (void)appSwitcherWillCreatePaymentMethod:(id<BTAppSwitching>)switcher;

@required

/// This message is sent when a payment method has been authorized and is available.
- (void)appSwitcher:(id<BTAppSwitching>)switcher didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod;

/// This message is sent when the payment method could not be created.
- (void)appSwitcher:(id<BTAppSwitching>)switcher didFailWithError:(NSError *)error;

/// This message is sent when the payment was cancelled.
- (void)appSwitcherDidCancel:(id<BTAppSwitching>)switcher;

@end


