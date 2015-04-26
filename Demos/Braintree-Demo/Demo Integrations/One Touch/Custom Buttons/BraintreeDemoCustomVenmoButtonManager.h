#import <UIKit/UIKit.h>

@class BTClient;
@protocol BTPaymentMethodCreationDelegate;

@interface BraintreeDemoCustomVenmoButtonManager : NSObject

- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTPaymentMethodCreationDelegate>)delegate;

@property (nonatomic, strong, readonly) UIButton *button;

@end
