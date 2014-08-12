#import <UIKit/UIKit.h>

@class Braintree;

@interface BraintreeDemoPayPalButtonDemoViewController : UIViewController
- (instancetype)initWithBraintree:(Braintree *)braintree completion:(void (^)(NSString *nonce))completionBlock;

@end
