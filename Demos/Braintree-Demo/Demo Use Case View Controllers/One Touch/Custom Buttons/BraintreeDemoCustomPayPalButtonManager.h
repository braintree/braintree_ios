#import <UIKit/UIKit.h>

@class BTClient;
@protocol BTPaymentMethodCreationDelegate;

@interface BraintreeDemoCustomPayPalButtonManager : NSObject

- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTPaymentMethodCreationDelegate>)delegate;

@property (nonatomic, strong, readonly) UIButton *button;

@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;

@end
