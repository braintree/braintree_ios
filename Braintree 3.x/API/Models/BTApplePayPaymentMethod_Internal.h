#if BT_ENABLE_APPLE_PAY
#import "BTApplePayPaymentMethod.h"

@interface BTApplePayPaymentMethod ()
@property (nonatomic, copy, readwrite) NSString *nonce;

@property (nonatomic, readwrite) ABRecordRef billingAddress;
@property (nonatomic, readwrite) ABRecordRef shippingAddress;
@property (nonatomic, strong, readwrite) PKShippingMethod *shippingMethod;

@end
#endif
