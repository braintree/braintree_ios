#import <UIKit/UIKit.h>
#import "BTCheckoutRequest.h"
#import "BTCheckout.h"
#import "BTPaymentOption.h"

BT_ASSUME_NONNULL_BEGIN

@protocol BTCheckoutButtonDelegate;

@interface BTCheckoutButton : UIView

- (instancetype)initWithCheckoutRequest:(BTCheckoutRequest *)checkoutRequest;

@property (nonatomic, nullable, strong) BTCheckoutRequest *checkoutRequest;

@property (nonatomic, weak, nullable) id<BTCheckoutButtonDelegate> delegate;

@end

@protocol BTCheckoutButtonDelegate <NSObject>

- (void)checkoutButton:(BTCheckoutButton *)button didCompleteCheckout:(BTCheckout *)checkout;

@optional

- (void)checkoutButton:(BTCheckoutButton *)button willAuthorizePaymentOption:(BTPaymentOption *)paymentOption;
- (void)checkoutButton:(BTCheckoutButton *)button didAuthorizePaymentOption:(BTPaymentOption *)paymentOption;

@end

BT_ASSUME_NONNULL_END
