#import "BTMockPKPaymentToken.h"

@implementation BTMockPKPaymentToken

- (instancetype)initWithPaymentMethod:(PKPaymentNetwork)paymentMethod {
    if (self = [super init]) {
        _mock = OCMClassMock(PKPaymentToken.class);
        OCMStub(_mock.paymentMethod).andReturn(paymentMethod);
    }
    return self;
}

@end
