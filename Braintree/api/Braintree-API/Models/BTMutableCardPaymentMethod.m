#import "BTMutableCardPaymentMethod.h"

@implementation BTMutableCardPaymentMethod

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BTCardTypeUnknown;
    }
    return self;
}


@end
