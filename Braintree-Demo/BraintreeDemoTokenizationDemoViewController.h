#import <UIKit/UIKit.h>

@class Braintree;

@interface BraintreeDemoTokenizationDemoViewController : UIViewController
- (instancetype)initWithBraintree:(Braintree *)braintree completion:(void (^)(NSString *nonce))completionBlock;
@end
