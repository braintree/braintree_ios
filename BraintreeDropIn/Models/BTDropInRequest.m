#import "BTDropInRequest.h"

@implementation BTDropInRequest

- (id)copyWithZone:(__unused NSZone *)zone {
    BTDropInRequest *request = [BTDropInRequest new];
    request.amount = self.amount;
    request.currencyCode = self.currencyCode;
    request.noShipping = self.noShipping;
    request.shippingAddress = self.shippingAddress;
    request.applePayDisabled = self.applePayDisabled;
    request.threeDSecureVerification = self.threeDSecureVerification;
    return request;
}

@end
