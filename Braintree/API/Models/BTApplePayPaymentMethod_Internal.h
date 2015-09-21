#if BT_ENABLE_APPLE_PAY
#import "BTApplePayPaymentMethod.h"

@interface BTApplePayPaymentMethod ()
@property (nonatomic, copy, readwrite) NSString *nonce;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, readwrite) ABRecordRef billingAddress;
@property (nonatomic, readwrite) ABRecordRef shippingAddress;
#pragma clang diagnostic pop
@property (nonatomic, readwrite, strong) PKContact *billingContact;
@property (nonatomic, readwrite, strong) PKContact *shippingContact;
@property (nonatomic, strong, readwrite) PKShippingMethod *shippingMethod;

@end
#endif
