#import "BTPaymentMethod.h"
#import "BTPaymentMethod_Mutable.h"

@implementation BTPaymentMethod
@synthesize description;

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" nonce:%@>", NSStringFromClass([self class]), self, [self description], self.nonce];
}

@end
