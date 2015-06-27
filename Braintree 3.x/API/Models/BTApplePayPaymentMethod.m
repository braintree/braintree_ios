#if BT_ENABLE_APPLE_PAY
#import "BTApplePayPaymentMethod_Internal.h"
#import "BTMutableApplePayPaymentMethod.h"

@implementation BTApplePayPaymentMethod

@synthesize nonce = _nonce;

- (id)copyWithZone:(NSZone *)zone {
    BTApplePayPaymentMethod *copy = [[BTApplePayPaymentMethod allocWithZone:zone] init];
    copy->_nonce = [self.nonce copy];
    copy->_shippingMethod = [self.shippingMethod copy];
    copy.billingAddress = self.billingAddress;
    copy.shippingAddress = self.shippingAddress;
    return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    BTMutableApplePayPaymentMethod *mutableInstance = [[BTMutableApplePayPaymentMethod allocWithZone:zone] init];
    [mutableInstance setNonce:self.nonce];
    [mutableInstance setShippingMethod:self.shippingMethod];
    [mutableInstance setShippingAddress:self.shippingAddress];
    [mutableInstance setBillingAddress:self.billingAddress];
    return mutableInstance;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<BTApplePayPaymentMethod:%p nonce:(%@) shippingAddress:%@ shippingMethod:(%@) billingAddress:%@>", self, self.nonce, self.shippingAddress, self.shippingMethod.label, self.billingAddress];
}

- (void)setShippingAddress:(ABRecordRef)shippingAddress {
    if (shippingAddress != NULL) {
        _shippingAddress = CFRetain(shippingAddress);
    }
}

- (void)setBillingAddress:(ABRecordRef)billingAddress {
    if (billingAddress != NULL) {
        _billingAddress = CFRetain(billingAddress);
    }
}

- (void)dealloc {
    if (_shippingAddress != NULL) {
        CFRelease(_shippingAddress);
    }
    if (_billingAddress != NULL) {
        CFRelease(_billingAddress);
    }
}

@end
#endif
