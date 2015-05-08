#import <Foundation/Foundation.h>
#import "BraintreeDemoBaseViewController.h"
#import <Braintree/Braintree.h>

@interface BraintreeDemoPaymentButtonBaseViewController : BraintreeDemoBaseViewController <BTPaymentMethodCreationDelegate>
@property(nonatomic, strong) Braintree *braintree;
- (UIView *)paymentButton;
@end
