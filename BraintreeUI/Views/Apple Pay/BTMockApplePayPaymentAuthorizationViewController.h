#if BT_ENABLE_APPLE_PAY
#import <UIKit/UIKit.h>
@import PassKit;

@protocol BTMockApplePayPaymentAuthorizationViewControllerDelegate;

@interface BTMockApplePayPaymentAuthorizationViewController : UIViewController

@property (nonatomic, weak) id<BTMockApplePayPaymentAuthorizationViewControllerDelegate> delegate;

- (instancetype)initWithPaymentRequest:(PKPaymentRequest *)request NS_DESIGNATED_INITIALIZER;

+ (BOOL)canMakePayments;

@end

@protocol BTMockApplePayPaymentAuthorizationViewControllerDelegate <NSObject>

- (void)mockApplePayPaymentAuthorizationViewController:(BTMockApplePayPaymentAuthorizationViewController *)viewController
                                  didAuthorizePayment:(PKPayment *)payment
                                           completion:(void (^)(PKPaymentAuthorizationStatus status))completion;

- (void)mockApplePayPaymentAuthorizationViewControllerDidFinish:(BTMockApplePayPaymentAuthorizationViewController *)viewController;

@end
#endif
