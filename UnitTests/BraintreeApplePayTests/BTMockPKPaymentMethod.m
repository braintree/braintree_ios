#import "BTMockPKPaymentMethod.h"

@implementation BTMockPKPaymentMethod

- (instancetype)initWithNetwork:(PKPaymentNetwork)network {
    if (self = [super init]) {
        _mock = OCMClassMock(PKPaymentMethod.class);
        OCMStub(_mock.network).andReturn(network);
    }
    return self;
}

@end
