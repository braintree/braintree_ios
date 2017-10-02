#import <UIKit/UIKit.h>
@import PassKit;

@protocol BTMockApplePayPaymentAuthorizationViewControllerDelegate;

@interface BTMockApplePayPaymentAuthorizationViewController : UIViewController

@property (nonatomic, weak) id<BTMockApplePayPaymentAuthorizationViewControllerDelegate> delegate;

- (instancetype)initWithPaymentRequest:(PKPaymentRequest *)request NS_AVAILABLE_IOS(8_0);

+ (BOOL)canMakePayments;

@end

@protocol BTMockApplePayPaymentAuthorizationViewControllerDelegate <NSObject>

- (void)mockApplePayPaymentAuthorizationViewController:(BTMockApplePayPaymentAuthorizationViewController *)viewController
                                  didAuthorizePayment:(PKPayment *)payment
                                           completion:(void (^)(PKPaymentAuthorizationStatus status))completion NS_AVAILABLE_IOS(8_0);

- (void)mockApplePayPaymentAuthorizationViewControllerDidFinish:(BTMockApplePayPaymentAuthorizationViewController *)viewController;

@end
