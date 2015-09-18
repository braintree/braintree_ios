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
    copy.billingContact = self.billingContact;
    copy.shippingContact = self.shippingContact;
    return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    BTMutableApplePayPaymentMethod *mutableInstance = [[BTMutableApplePayPaymentMethod allocWithZone:zone] init];
    [mutableInstance setNonce:self.nonce];
    [mutableInstance setShippingMethod:self.shippingMethod];
    [mutableInstance setShippingAddress:self.shippingAddress];
    [mutableInstance setBillingAddress:self.billingAddress];
    [mutableInstance setShippingContact:self.shippingContact];
    [mutableInstance setBillingContact:self.billingContact];
    return mutableInstance;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<BTApplePayPaymentMethod:%p nonce:(%@) shippingMethod:(%@) ", self, self.nonce, self.shippingAddress];
    
    if (self.shippingContact) {
        [description appendFormat:@"shippingContact: %@ ", self.shippingContact];
    } else if (self.shippingAddress) {
        [description appendFormat:@"shippingAddress: %@ ", self.shippingAddress];
    }
    
    if (self.billingContact) {
        [description appendFormat:@"billingContact: %@ ", self.billingContact];
    } else if (self.billingAddress) {
        [description appendFormat:@"billingAddress: %@ ", self.billingAddress];
    }
    
    [description appendString:@">"];
    
    return [description copy];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

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

#pragma clang diagnostic pop

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
