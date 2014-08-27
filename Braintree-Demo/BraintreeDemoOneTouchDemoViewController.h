#import <UIKit/UIKit.h>

@class Braintree;

@interface BraintreeDemoOneTouchDemoViewController : UIViewController
- (instancetype)initWithBraintree:(Braintree *)braintree completion:(void (^)(NSString *nonce))completionBlock;

@end
