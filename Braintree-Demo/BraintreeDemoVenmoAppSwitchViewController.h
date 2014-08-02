#import <UIKit/UIKit.h>

#import <Braintree/Braintree.h>

@interface BraintreeDemoVenmoAppSwitchViewController : UIViewController

- (instancetype)initWithBraintree:(Braintree *)braintree
                       merchantID:(NSString *)merchantID
                       completion:(void(^)(NSString *nonce))completionBlock;

@end
