@import PassKit;

#import "BTClientApplePayConfiguration.h"

@implementation BTClientApplePayConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (PKPaymentRequest *)paymentRequest {
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.currencyCode = self.currencyCode;
    paymentRequest.countryCode = self.countryCode;
    paymentRequest.merchantIdentifier = self.merchantIdentifier;
    paymentRequest.supportedNetworks = self.supportedNetworks;
    return paymentRequest;
}

@end
