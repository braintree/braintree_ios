#import "BTPaymentApp.h"

@implementation BTPaymentApp

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" scheme:%@>", NSStringFromClass([self class]), self, self.label, self.scheme];
}

@end
