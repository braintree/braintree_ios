#import "BTClient_Internal.h"
#import "BTClientPayPalPaymentResourceValueTransformer.h"
#import "BTClient+BTPayPal.h"

@implementation BTClient (BTPayPal)

- (void)createPayPalPaymentResourceWithCheckout:(BTPayPalCheckout *)checkout
                                    redirectUri:(NSString *)redirectUri
                                      cancelUri:(NSString *)cancelUri
                               clientMetadataID:(NSString *)clientMetadataID
                                        success:(BTClientPayPalPaymentResourceBlock)successBlock
                                        failure:(BTClientFailureBlock)failureBlock {
    
    NSMutableDictionary *experienceProfileParams = [@{@"no_shipping":(checkout.enableShippingAddress ? @NO : @YES)} mutableCopy];
    if (checkout.localeCode != nil) {
        [experienceProfileParams setValue:checkout.localeCode forKey:@"locale_code"];
    }
    
    NSDictionary *shippingAddress;
    if (checkout.addressOverride && checkout.shippingAddress != nil) {
        [experienceProfileParams setValue:(checkout.addressOverride ? @YES : @NO) forKey:@"address_override"];
        shippingAddress = @{ @"line1": checkout.shippingAddress.streetAddress ?: @"",
                             @"line2": checkout.shippingAddress.extendedAddress ?: @"",
                             @"city": checkout.shippingAddress.locality ?: @"",
                             @"state": checkout.shippingAddress.region ?: @"",
                             @"postal_code": checkout.shippingAddress.postalCode ?: @"",
                             @"country_code": checkout.shippingAddress.countryCodeAlpha2 ?: @"",
                             @"recipient_name": checkout.shippingAddress.recipientName ?: @""
                             };
    }
    
    NSMutableDictionary *parameters = [@{ @"authorization_fingerprint": self.clientToken.authorizationFingerprint,
                                          @"amount": [checkout.amount stringValue],
                                          @"currency_iso_code": checkout.currencyCode ?: self.configuration.payPalCurrencyCode,
                                          @"return_url": redirectUri,
                                          @"cancel_url": cancelUri,
                                          @"experience_profile": experienceProfileParams,
                                          @"correlation_id": clientMetadataID
                                          } mutableCopy];
    
    if (shippingAddress != nil) {
        [parameters addEntriesFromDictionary:shippingAddress];
    }
    
    [self.clientApiHttp POST:@"v1/paypal_hermes/create_payment_resource"
                  parameters:parameters
                  completion:^(BTHTTPResponse *response, NSError *error) {
                      if (response.isSuccess) {
                          if (successBlock) {
                              successBlock([response.object objectForKey:@"paymentResource" withValueTransformer:[BTClientPayPalPaymentResourceValueTransformer sharedInstance]]);
                          }
                      } else {
                          if (failureBlock) {
                              failureBlock(error);
                          }
                      }
                  }];
}

@end
