#import <UIKit/UIKit.h>
#import "BTCheckoutRequest.h"
#import "BTCheckout.h"

BT_ASSUME_NONNULL_BEGIN

@protocol BTCheckoutViewControllerDelegate;

@interface BTCheckoutViewController : UIViewController

- (instancetype)initWithCheckoutRequest:(BTCheckoutRequest *)checkoutRequest;

@property (nonatomic, nullable, strong) BTCheckoutRequest *checkoutRequest;

@property (nonatomic, nullable, weak) id<BTCheckoutViewControllerDelegate> delegate;

@end

@protocol BTCheckoutViewControllerDelegate <NSObject>

@optional

- (void)checkoutViewController:(BTCheckoutViewController *)viewController
          willCompleteCheckout:(BTCheckout *)checkout
                    completion:(void (^)(BOOL success))completionBlock;

@required

- (void)checkoutViewController:(BTCheckoutViewController *)viewController
           didCompleteCheckout:(BTCheckout *)checkout;

@optional

- (void)checkoutViewController:(BTCheckoutViewController *)viewController willAuthorizePaymentOption:(BTPaymentOption *)paymentOption;
- (void)checkoutViewController:(BTCheckoutViewController *)viewController didAuthorizePaymentOption:(BTPaymentOption *)paymentOption;

@end

BT_ASSUME_NONNULL_END
