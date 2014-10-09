@import UIKit;

@protocol BTMockApplePayPaymentAuthorizationViewDelegate;

@interface BTMockApplePayPaymentAuthorizationView : UIView

- (instancetype)initWithDelegate:(id<BTMockApplePayPaymentAuthorizationViewDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end

@protocol BTMockApplePayPaymentAuthorizationViewDelegate <NSObject>

- (void)mockApplePayPaymentAuthorizationViewDidSucceed:(BTMockApplePayPaymentAuthorizationView *)view;
- (void)mockApplePayPaymentAuthorizationViewDidCancel:(BTMockApplePayPaymentAuthorizationView *)view;

@end
