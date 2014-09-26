@import Foundation;
@import PassKit;

typedef NS_ENUM(NSUInteger, BTClientApplePayStatus) {
    BTClientApplePayStatusOff = 0,
    BTClientApplePayStatusMock = 1,
    BTClientApplePayStatusProduction = 2,
};

@interface BTClientApplePayConfiguration : NSObject

@property (nonatomic, assign) BTClientApplePayStatus status;

@property (nonatomic, readonly, strong) PKPaymentRequest *paymentRequest;

- (void)setCountryCode:(NSString *)countryCode;
- (void)setCurrencyCode:(NSString *)currencyCode;
- (void)setMerchantIdentifier:(NSString *)merchantIdentifier;
- (void)setSupportedNetworks:(NSArray *)supportedNetworks;

@end
