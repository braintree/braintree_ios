#import <UIKit/UIKit.h>

#import "BTUIThemedView.h"

@class BTClient, BTPaymentMethod;
@protocol BTPaymentAuthorizerDelegate;

@interface BTPaymentButton : BTUIThemedView

- (instancetype)initWithPaymentAuthorizationTypes:(NSOrderedSet *)paymentAuthorizationTypes;

@property (nonatomic, strong) NSOrderedSet *enabledPaymentAuthorizationTypes;

@property (nonatomic, strong) BTClient *client;
@property (nonatomic, weak) id<BTPaymentAuthorizerDelegate> delegate;

@end
