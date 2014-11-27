#import <UIKit/UIKit.h>

@class Braintree;

@interface BraintreeDemoBraintreeInitializationDemoViewController : UIViewController
- (instancetype)initWithCompletion:(void (^)(Braintree *braintree, NSString *currentMerchantName, NSError *error))completionBlock;
@end
