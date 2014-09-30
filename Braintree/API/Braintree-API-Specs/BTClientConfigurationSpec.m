#import "BTClientConfiguration.h"

SpecBegin(BTClientConfiguration)

describe(@"apple pay configuration", ^{
    it(@"creates an empty payment request lazily if the PKPaymentRequest object is available", ^{
        BTClientConfiguration *configuration = [[BTClientConfiguration alloc] init];
        configuration.applePayConfiguration = [[BTClientApplePayConfiguration alloc] init];

        if ([PKPayment class]) {
            expect(configuration.applePayConfiguration.paymentRequest).to.beKindOf([PKPaymentRequest class]);
            expect(configuration.applePayConfiguration.paymentRequest).to.beIdenticalTo(configuration.applePayConfiguration.paymentRequest);
        } else {
            expect(configuration.applePayConfiguration.paymentRequest).to.beNil();
        }
    });
});

SpecEnd
