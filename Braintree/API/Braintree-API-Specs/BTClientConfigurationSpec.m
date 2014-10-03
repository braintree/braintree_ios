#import "BTClientConfiguration.h"

SpecBegin(BTClientConfiguration)

describe(@"apple pay configuration", ^{
    if ([PKPayment class]) {
        it(@"creates an empty payment request lazily if the PKPaymentRequest object is available", ^{
            BTClientConfiguration *configuration = [[BTClientConfiguration alloc] init];
            configuration.applePayConfiguration = [[BTClientApplePayConfiguration alloc] init];

            expect(configuration.applePayConfiguration.paymentRequest).to.beKindOf([PKPaymentRequest class]);
            expect(configuration.applePayConfiguration.paymentRequest).to.beIdenticalTo(configuration.applePayConfiguration.paymentRequest);
        });

        it(@"sets default settings for the PKPaymentRequest", ^{
            BTClientConfiguration *configuration = [[BTClientConfiguration alloc] init];
            configuration.applePayConfiguration = [[BTClientApplePayConfiguration alloc] init];

            expect(configuration.applePayConfiguration.paymentRequest.merchantCapabilities).to.equal(PKMerchantCapability3DS);
        });
    } else {
        it(@"has a nil PKPaymentRequest when Apple Pay is not available", ^{
            BTClientConfiguration *configuration = [[BTClientConfiguration alloc] init];
            configuration.applePayConfiguration = [[BTClientApplePayConfiguration alloc] init];

            expect(configuration.applePayConfiguration.paymentRequest).to.beKindOf([PKPaymentRequest class]);
            expect(configuration.applePayConfiguration.paymentRequest).to.beNil();
        });
    }
});

SpecEnd
