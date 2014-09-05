#import <Foundation/Foundation.h>

@class Braintree;
@protocol BTPaymentMethodCreationDelegate;

@interface BraintreeDemoCustomMultiPaymentButtonManager : NSObject

- (instancetype)initWithBraintree:(Braintree *)braintree delegate:(id<BTPaymentMethodCreationDelegate>)delegate;

@property (nonatomic, strong, readonly) UIView *view;

@end
