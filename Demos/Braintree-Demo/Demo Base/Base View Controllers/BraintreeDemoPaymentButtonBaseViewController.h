#import <Foundation/Foundation.h>
#import "BraintreeDemoBaseViewController.h"
#import <BraintreeCore/BraintreeCore.h>

@interface BraintreeDemoPaymentButtonBaseViewController : BraintreeDemoBaseViewController
@property (nonatomic, strong) BTAPIClient *apiClient;
- (UIView *)paymentButton;
@end
