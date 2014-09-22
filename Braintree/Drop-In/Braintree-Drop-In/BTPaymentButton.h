@import UIKit;

#import "BTUIThemedView.h"

@class BTClient, BTPaymentMethod;
@protocol BTPaymentMethodCreationDelegate;

@interface BTPaymentButton : BTUIThemedView

- (instancetype)initWithPaymentProviderTypes:(NSOrderedSet *)paymentAuthorizationTypes;
- (id)initWithFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (id)init;

@property (nonatomic, strong) NSOrderedSet *enabledPaymentProviderTypes;

@property (nonatomic, strong) BTClient *client;
@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;

@end
