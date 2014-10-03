@import PassKit;

#import "BTClientApplePayConfiguration.h"

@implementation BTClientApplePayConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
        _paymentRequest = [[PKPaymentRequest alloc] init];
        _paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    }
    return self;
}

- (void)setCountryCode:(NSString *)countryCode {
    self.paymentRequest.countryCode = countryCode;
}

- (void)setCurrencyCode:(NSString *)currencyCode {
    self.paymentRequest.currencyCode = currencyCode;
}

- (void)setMerchantIdentifier:(NSString *)merchantIdentifier {
    self.paymentRequest.merchantIdentifier = merchantIdentifier;
}

- (void)setSupportedNetworks:(NSArray *)supportedNetworks {
    self.paymentRequest.supportedNetworks = supportedNetworks;
}

@end
