@import UIKit;
@import PassKit;

@protocol BTMockApplePayPaymentAuthorizationViewControllerDelegate;

@interface BTMockApplePayPaymentAuthorizationViewController : UIViewController

@property (nonatomic, weak) id<BTMockApplePayPaymentAuthorizationViewControllerDelegate> delegate;

@end

@protocol BTMockApplePayPaymentAuthorizationViewControllerDelegate <NSObject>

- (void)mockApplePayPaymentAuthorizationViewController:(BTMockApplePayPaymentAuthorizationViewController *)viewController
                                  didAuthorizePayment:(PKPayment *)payment
                                           completion:(void (^)(PKPaymentAuthorizationStatus status))completion;

- (void)mockApplePayPaymentAuthorizationViewControllerDidFinish:(BTMockApplePayPaymentAuthorizationViewController *)viewController;

@end