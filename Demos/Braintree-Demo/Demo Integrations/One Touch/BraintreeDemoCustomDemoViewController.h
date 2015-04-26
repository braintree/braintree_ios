#import <UIKit/UIKit.h>

@class Braintree;

@interface BraintreeDemoCustomDemoViewController : UIViewController

- (instancetype)initWithBraintree:(Braintree *)braintree completion:(void (^)(NSString *nonce))completionBlock;

@end
