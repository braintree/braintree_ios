#import <UIKit/UIKit.h>

#import "BTPaymentMethodAuthorizationDelegate.h"
#import "BTUIThemedView.h"

@class BTClient, BTPaymentMethod;
@protocol BTPaymentMethodAuthorizationDelegate;

// TODO: Remove this type and unify it with other similar notions
typedef NS_OPTIONS(NSInteger, BTPaymentButtonPaymentMethods) {
    BTPaymentButtonPaymentMethodVenmo = 1 << 0,
    BTPaymentButtonPaymentMethodPayPal = 1 << 1,
    BTPaymentButtonPaymentMethodAll = BTPaymentButtonPaymentMethodVenmo | BTPaymentButtonPaymentMethodPayPal,
};

@interface BTPaymentButton : BTUIThemedView

// TODO: Refactor to use a unified notion of PaymentMethodTypes
@property (nonatomic, strong) NSOrderedSet *enabledPaymentMethods;

@property (nonatomic, strong) BTClient *client;
@property (nonatomic, weak) id<BTPaymentMethodAuthorizationDelegate> delegate;

@end
