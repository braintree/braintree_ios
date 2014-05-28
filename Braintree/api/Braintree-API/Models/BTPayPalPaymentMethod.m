#import "BTPayPalPaymentMethod_Mutable.h"

@implementation BTPayPalPaymentMethod

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" email:%@ nonce:%@>", NSStringFromClass([self class]), self, self.email, [self description], self.nonce];
}

@end
