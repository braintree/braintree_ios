#if BT_ENABLE_APPLE_PAY
#import <UIKit/UIKit.h>

@protocol BTMockApplePayPaymentAuthorizationViewDelegate;

@interface BTMockApplePayPaymentAuthorizationView : UIView

- (instancetype)initWithDelegate:(id<BTMockApplePayPaymentAuthorizationViewDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end

@protocol BTMockApplePayPaymentAuthorizationViewDelegate <NSObject>

- (void)mockApplePayPaymentAuthorizationViewDidSucceed:(BTMockApplePayPaymentAuthorizationView *)view;
- (void)mockApplePayPaymentAuthorizationViewDidCancel:(BTMockApplePayPaymentAuthorizationView *)view;

@end
#endif
