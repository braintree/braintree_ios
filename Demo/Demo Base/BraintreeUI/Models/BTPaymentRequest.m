#import "BTPaymentRequest.h"

@implementation BTPaymentRequest

- (instancetype)init
{
    if (self = [super init]) {
        _displayAmount = @""; // Use empty string as default value for this non-nullable property.
        _callToActionText = @""; // Default value for this non-nullable property.
        _showDefaultPaymentMethodNonceFirst = NO;
    }
    return self;
}

- (id)copyWithZone:(__unused NSZone *)zone {
    BTPaymentRequest *request = [BTPaymentRequest new];
    request.summaryTitle = self.summaryTitle;
    request.summaryDescription = self.summaryDescription;
    request.displayAmount = self.displayAmount;
    request.callToActionText = self.callToActionText;
    request.shouldHideCallToAction = self.shouldHideCallToAction;
    request.amount = self.amount;
    request.currencyCode = self.currencyCode;
    request.noShipping = self.noShipping;
    request.presentViewControllersFromTop = self.presentViewControllersFromTop;
    request.shippingAddress = self.shippingAddress;
    request.showDefaultPaymentMethodNonceFirst = self.showDefaultPaymentMethodNonceFirst;
    return request;
}

@end
