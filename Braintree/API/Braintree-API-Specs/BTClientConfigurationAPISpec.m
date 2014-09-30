#import "BTClientConfigurationAPI.h"
#import "BTClientConfiguration.h"

SpecBegin(BTClientConfigurationAPI)

describe(@"Creating BTClientConfiguration from API responses", ^{
    __block NSDictionary *validConfiguration = @{
                                                 @"version": @3,
                                                 @"applePay": @{
                                                         @"status": @"mock",
                                                         @"countryCode": @"US",
                                                         @"currencyCode": @"USD",
                                                         @"merchantIdentifier": @"apple-pay-merchant-id",
                                                         @"supportedNetworks": @[ @"visa", @"amex", @"mastercard" ]
                                                         }
                                                 };

    it(@"constructs a BTClientConfiguration", ^{
        NSError *error;
        BTClientConfiguration *c = [BTClientConfigurationAPI modelWithAPIDictionary:@{}
                                                                              error:&error];
        expect(c).to.beKindOf([BTClientConfiguration class]);
    });

    if (![PKPayment class]) {
        it(@"ignores Apple Pay configuration in old SDKs where Apple Pay does not exist", ^{
            NSError *error;
            BTClientConfiguration *c = [BTClientConfigurationAPI modelWithAPIDictionary:validConfiguration
                                                                                  error:&error];
            expect(error).to.beNil();
            expect(c.applePayConfiguration.status).to.equal(BTClientApplePayStatusOff);
        });
    } else {
        it(@"accepts a nil Apple Pay configuration when Apple Pay is off", ^{
            NSMutableDictionary *configuration = [validConfiguration mutableCopy];
            [configuration removeObjectForKey:@"applePay"];
            NSError *error;
            BTClientConfiguration *c = [BTClientConfigurationAPI modelWithAPIDictionary:configuration
                                                                                  error:&error];
            expect(error).to.beNil();
            expect(c.applePayConfiguration).to.beNil();
        });

        it(@"parses an Apple Pay configuration when in mock mode", ^{
            NSError *error;
            BTClientConfiguration *c = [BTClientConfigurationAPI modelWithAPIDictionary:validConfiguration
                                                                                  error:&error];
            expect(error).to.beNil();
            expect(c.applePayConfiguration.status).to.equal(BTClientApplePayStatusMock);
        });

        it(@"parses an Apple Pay configuration payment request in mock mode", ^{
            NSError *error;
            BTClientConfiguration *c = [BTClientConfigurationAPI modelWithAPIDictionary:validConfiguration
                                                                                  error:&error];
            expect(error).to.beNil();

            expect(c.applePayConfiguration.paymentRequest.countryCode).to.equal(@"US");
            expect(c.applePayConfiguration.paymentRequest.currencyCode).to.equal(@"USD");
            expect(c.applePayConfiguration.paymentRequest.merchantIdentifier).to.equal(@"apple-pay-merchant-id");
            expect(c.applePayConfiguration.paymentRequest.supportedNetworks).to.contain(PKPaymentNetworkAmex);
            expect(c.applePayConfiguration.paymentRequest.supportedNetworks).to.contain(PKPaymentNetworkVisa);
            expect(c.applePayConfiguration.paymentRequest.supportedNetworks).to.contain(PKPaymentNetworkMasterCard);

            expect(c.applePayConfiguration.paymentRequest.paymentSummaryItems).to.beNil();
            expect(c.applePayConfiguration.paymentRequest.billingAddress).to.beNil();
            expect(c.applePayConfiguration.paymentRequest.requiredBillingAddressFields).to.equal(PKAddressFieldNone);
            expect(c.applePayConfiguration.paymentRequest.shippingAddress).to.beNil();
            expect(c.applePayConfiguration.paymentRequest.requiredShippingAddressFields).to.equal(PKAddressFieldNone);
            expect(c.applePayConfiguration.paymentRequest.shippingMethods).to.beNil();

            expect(c.applePayConfiguration.paymentRequest.applicationData).to.beNil();
        });

        it(@"parses an Apple Pay configuration payment request in mock mode that supports fewer payment networks", ^{
            NSMutableDictionary *configuration = [validConfiguration mutableCopy];
            NSMutableDictionary *applePayConfiguration = [configuration[@"applePay"] mutableCopy];
            applePayConfiguration[@"supportedNetworks"] = @[ @"amex" ];
            configuration[@"applePay"] = applePayConfiguration;
            NSError *error;
            BTClientConfiguration *c = [BTClientConfigurationAPI modelWithAPIDictionary:configuration
                                                                                  error:&error];
            expect(error).to.beNil();
            expect(c.applePayConfiguration.paymentRequest.supportedNetworks).to.equal(@[PKPaymentNetworkAmex]);
        });
    }
});

SpecEnd
