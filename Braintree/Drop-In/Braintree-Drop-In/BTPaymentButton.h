#import <UIKit/UIKit.h>

#import "BTPaymentMethodAuthorizationDelegate.h"

@class BTClient, BTPaymentMethod;
@protocol BTPaymentMethodAuthorizationDelegate;

typedef NS_OPTIONS(NSInteger, BTPaymentButtonPaymentMethods) {
    BTPaymentButtonPaymentMethodVenmo,
    BTPaymentButtonPaymentMethodPayPal,
    BTPaymentButtonPaymentMethodAll = BTPaymentButtonPaymentMethodVenmo | BTPaymentButtonPaymentMethodPayPal,
};

@interface BTPaymentButton : UIView

@property (nonatomic, assign) BTPaymentButtonPaymentMethods enabledPaymentMethods;

@property (nonatomic, strong) BTClient *client;
@property (nonatomic, weak) id<BTPaymentMethodAuthorizationDelegate> delegate;

@end
