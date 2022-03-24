#import <Foundation/Foundation.h>
#import "BraintreeDemoBaseViewController.h"
@class BTAPIClient;

@interface BraintreeDemoPaymentButtonBaseViewController : BraintreeDemoBaseViewController

@property (nonatomic, strong) BTAPIClient *apiClient;
@property (nonatomic, strong) UIView *paymentButton;
@property (nonatomic, readwrite) CGFloat centerYConstant;

/// A factory method that subclasses must implement to return a payment button view.
- (UIView *)createPaymentButton;

@end
