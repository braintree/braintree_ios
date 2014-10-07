#import "BTClientConfiguration.h"

SpecBegin(BTClientConfiguration)

describe(@"apple pay configuration", ^{
    if ([PKPayment class]) {
        it(@"constructs an empty payment request if the PKPaymentRequest class is available", ^{
            BTClientConfiguration *configuration = [[BTClientConfiguration alloc] init];
            configuration.applePayConfiguration = [[BTClientApplePayConfiguration alloc] init];

            expect(configuration.applePayConfiguration.paymentRequest).to.beKindOf([PKPaymentRequest class]);
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
