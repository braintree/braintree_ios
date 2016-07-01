#import "BTDropInRequest.h"

@implementation BTDropInRequest

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (id)copyWithZone:(__unused NSZone *)zone {
    BTDropInRequest *request = [BTDropInRequest new];
    request.amount = self.amount;
    request.currencyCode = self.currencyCode;
    request.noShipping = self.noShipping;
    request.shippingAddress = self.shippingAddress;
    request.canMakeApplePayPayments = self.canMakeApplePayPayments;
    return request;
}

@end
