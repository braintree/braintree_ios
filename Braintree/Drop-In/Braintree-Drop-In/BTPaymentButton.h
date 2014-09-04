#import <UIKit/UIKit.h>

#import "BTUIThemedView.h"

@class BTClient, BTPaymentMethod;
@protocol BTPaymentAuthorizerDelegate;

@interface BTPaymentButton : BTUIThemedView

// TODO: Refactor to use a unified notion of PaymentMethodTypes
@property (nonatomic, strong) NSOrderedSet *enabledPaymentMethods;

@property (nonatomic, strong) BTClient *client;
@property (nonatomic, weak) id<BTPaymentAuthorizerDelegate> delegate;

@end
