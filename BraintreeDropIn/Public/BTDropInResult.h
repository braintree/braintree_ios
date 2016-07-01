#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTKPaymentOptionType.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTDropInResult : NSObject

/// True if the modal was dismissed without selecting a payment method
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;

/// The type of the payment option
@property (nonatomic, assign) BTKPaymentOptionType paymentOptionType;

/// A UIView (BTKPaymentOptionCardView) that represents the payment option
@property (nonatomic, readonly) UIView *paymentIcon;

/// A description of the payment option (e.g `ending in 1234`)
@property (nonatomic, readonly) NSString *paymentDescription;

/// The payment method nonce
@property (nonatomic, strong, nullable) BTPaymentMethodNonce *paymentMethod;

@end

NS_ASSUME_NONNULL_END
