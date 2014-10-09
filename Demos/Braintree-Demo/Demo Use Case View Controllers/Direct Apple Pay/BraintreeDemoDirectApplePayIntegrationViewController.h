@import UIKit;
#import <Braintree/Braintree.h>

@interface BraintreeDemoDirectApplePayIntegrationViewController : UIViewController

- (instancetype)initWithBraintree:(Braintree *)braintree completion:(void (^)(NSString *nonce))completion;

@end
