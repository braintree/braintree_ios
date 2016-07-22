#import "BTDropInRequest.h"

@implementation BTDropInRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.displayCardTypes = @[];
    }
    return self;
}

- (id)copyWithZone:(__unused NSZone *)zone {
    BTDropInRequest *request = [BTDropInRequest new];
    request.amount = self.amount;
    request.currencyCode = self.currencyCode;
    request.noShipping = self.noShipping;
    request.shippingAddress = self.shippingAddress;
    request.showApplePayPaymentOption = self.showApplePayPaymentOption;
    request.displayCardTypes = [self.displayCardTypes copy];
    request.threeDSecureVerification = self.threeDSecureVerification;
    return request;
}

@end
