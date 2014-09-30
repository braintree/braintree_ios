#import "BTClientApplePayConfiguration.h"

@implementation BTClientApplePayConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (PKPaymentRequest *)paymentRequest {
    static dispatch_once_t onceToken;
    static PKPaymentRequest *paymentRequest;
    dispatch_once(&onceToken, ^{
        paymentRequest = [[PKPaymentRequest alloc] init];
    });
    return paymentRequest;
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
