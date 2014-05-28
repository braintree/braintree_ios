#import "BTPayPalAccount_Mutable.h"

@implementation BTPayPalAccount

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" email:%@ nonce:%@>", NSStringFromClass([self class]), self, self.email, [self description], self.nonce];
}

@end
