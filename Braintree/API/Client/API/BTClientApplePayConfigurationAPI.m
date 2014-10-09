@import PassKit;

#import "BTClientApplePayConfigurationAPI.h"
#import "BTClientApplePayConfiguration.h"

@implementation BTClientApplePayConfigurationAPI

+ (Class)resourceModelClass {
    return [BTClientApplePayConfiguration class];
}

+ (NSDictionary *)APIFormat {
    if (![PKPayment class]) {
        return @{};
    }
    
    return @{
             @"status": BTAPIResourceValueTypeEnumMapping(@selector(setStatus:), @{
                                                                                   @"off": @(BTClientApplePayStatusOff),
                                                                                   @"mock": @(BTClientApplePayStatusMock),
                                                                                   @"production": @(BTClientApplePayStatusProduction),
                                                                                   }),
             @"countryCode": BTAPIResourceValueTypeString(@selector(setCountryCode:)),
             @"currencyCode": BTAPIResourceValueTypeString(@selector(setCurrencyCode:)),
             @"merchantIdentifier": BTAPIResourceValueTypeString(@selector(setMerchantIdentifier:)),
             @"supportedNetworks": BTAPIResourceValueTypeMap(BTAPIResourceValueTypeStringArray(@selector(setSupportedNetworks:)), @{
                                                                                                                                    @"amex": PKPaymentNetworkAmex,
                                                                                                                                    @"visa": PKPaymentNetworkVisa,
                                                                                                                                    @"mastercard": PKPaymentNetworkMasterCard,
                                                                                                                                    }),
             };
}

@end