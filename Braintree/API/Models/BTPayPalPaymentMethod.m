#import "BTPayPalPaymentMethod_Mutable.h"
#import "BTMutablePayPalPaymentMethod.h"

@implementation BTPayPalPaymentMethod

- (id)mutableCopyWithZone:(__unused NSZone *)zone {
    BTMutablePayPalPaymentMethod *mutablePayPalPaymentMethod = [[BTMutablePayPalPaymentMethod alloc] init];
    mutablePayPalPaymentMethod.billingAddress = self.billingAddress;
    mutablePayPalPaymentMethod.email = self.email;
    mutablePayPalPaymentMethod.locked = self.locked;
    mutablePayPalPaymentMethod.nonce = self.nonce;
    mutablePayPalPaymentMethod.challengeQuestions = [self.challengeQuestions copy];
    mutablePayPalPaymentMethod.description = self.description;

    return mutablePayPalPaymentMethod;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" email:%@ nonce:%@ billingAddress:%@>", NSStringFromClass([self class]), self, self.email, [self description], self.nonce, self.billingAddress];
}

@end
