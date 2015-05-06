#import <UIKit/UIKit.h>

@class Braintree;

@interface BraintreeDemoPaymentButtonDemoViewController : UIViewController
- (instancetype)initWithBraintree:(Braintree *)braintree completion:(void (^)(NSString *nonce))completionBlock;

@end
