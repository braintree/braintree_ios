#import "BTClientApplePayConfiguration.h"

SpecBegin(BTClientApplePayConfiguration)

describe(@"initWithDictionary:", ^{

    it(@"is initialized with a dictionary", ^{
        BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithDictionary:@{}];
        expect(configuration.status).to.equal(BTClientApplePayStatusOff);
    });

    it(@"is off if initialized with nil dictionary", ^{
        BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithDictionary:nil];
        expect(configuration.status).to.equal(BTClientApplePayStatusOff);
    });

    it(@"is initialized and has status off when status is 'off'", ^{
        BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithDictionary:@{@"status": @"off"}];
        expect(configuration.status).to.equal(BTClientApplePayStatusOff);
    });

    it(@"is initialized and has status off when status is 'I AM OFF'", ^{
        BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithDictionary:@{@"status": @"i am off"}];
        expect(configuration.status).to.equal(BTClientApplePayStatusOff);
    });

    it(@"is initialized and has status mock when status is 'mock'", ^{
        BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithDictionary:@{@"status": @"mock"}];
        expect(configuration.status).to.equal(BTClientApplePayStatusMock);
    });

    it(@"is initialized and has status production when status is 'production'", ^{
        BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithDictionary:@{@"status": @"production"}];
        expect(configuration.status).to.equal(BTClientApplePayStatusProduction);
    });

    it(@"does not have a merchant id if no merchant id key is present", ^{
        BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithDictionary:@{}];
        expect(configuration.merchantId).to.beNil();
    });

    it(@"has a merchant id if a merchant id key is present", ^{
        BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithDictionary:@{@"merchantId": @"1234"}];
        expect(configuration.merchantId).to.equal(@"1234");
    });
});

SpecEnd
