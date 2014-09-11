#import <Foundation/Foundation.h>

@class BTClient;
@protocol BTPaymentMethodCreationDelegate;

@interface BraintreeDemoCustomApplePayButtonManager : NSObject

- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTPaymentMethodCreationDelegate>)delegate;

@property (nonatomic, strong, readonly) UIButton *button;

@end
