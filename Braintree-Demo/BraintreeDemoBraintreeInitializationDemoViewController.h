#import <UIKit/UIKit.h>

@class Braintree;

@interface BraintreeDemoBraintreeInitializationDemoViewController : UIViewController
- (instancetype)initWithCompletion:(void (^)(Braintree *braintree, NSError *error))completionBlock;
@end