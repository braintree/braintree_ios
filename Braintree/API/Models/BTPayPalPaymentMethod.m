#import "BTPayPalPaymentMethod_Mutable.h"
#import "BTMutablePayPalPaymentMethod.h"

@implementation BTPayPalPaymentMethod

- (void)setEmail:(NSString *)email {
    _email = [email copy];
}

- (id)mutableCopyWithZone:(__unused NSZone *)zone {
    BTMutablePayPalPaymentMethod *mutablePayPalPaymentMethod = [[BTMutablePayPalPaymentMethod alloc] init];
    mutablePayPalPaymentMethod.billingAddress = self.billingAddress;
    mutablePayPalPaymentMethod.shippingAddress = self.shippingAddress;
    mutablePayPalPaymentMethod.email = self.email;
    mutablePayPalPaymentMethod.firstName = self.firstName;
    mutablePayPalPaymentMethod.lastName = self.lastName;
    mutablePayPalPaymentMethod.phone = self.phone;
    mutablePayPalPaymentMethod.locked = self.locked;
    mutablePayPalPaymentMethod.nonce = self.nonce;
    mutablePayPalPaymentMethod.challengeQuestions = [self.challengeQuestions copy];
    mutablePayPalPaymentMethod.description = self.description;

    return mutablePayPalPaymentMethod;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" email:%@ nonce:%@ billingAddress:%@>", NSStringFromClass([self class]), self, [self description], self.email, self.nonce, self.billingAddress];
}

@end
