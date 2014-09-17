#import "BTClientApplePayConfiguration.h"
#import "BTLogger.h"

SpecBegin(BTClientApplePayConfiguration)

describe(@"initWithConfigurationObject:", ^{

    context(@"when argument is a dictionary", ^{
        it(@"is initialized with a dictionary", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@{}];
            expect(configuration.status).to.equal(BTClientApplePayStatusOff);
        });

        it(@"is initialized and has status off when status is 'off'", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@{@"status": @"off"}];
            expect(configuration.status).to.equal(BTClientApplePayStatusOff);
        });

        it(@"is initialized and has status off when status is 'I AM ON'", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@{@"status": @"i am off"}];
            expect(configuration.status).to.equal(BTClientApplePayStatusOff);
        });

        it(@"is initialized and has status mock when status is 'mock'", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@{@"status": @"mock"}];
            expect(configuration.status).to.equal(BTClientApplePayStatusMock);
        });

        it(@"is initialized and has status production when status is 'production'", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@{@"status": @"production"}];
            expect(configuration.status).to.equal(BTClientApplePayStatusProduction);
        });

        it(@"does not have a merchant id if no merchant id key is present", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@{}];
            expect(configuration.merchantId).to.beNil();
        });

        it(@"has a merchant id if a merchant id key is present", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@{@"merchantId": @"1234"}];
            expect(configuration.merchantId).to.equal(@"1234");
        });
    });

    context(@"when argument is a string", ^{
        it(@"has status off when argument is 'I AM ON'", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@"I AM ON"];
            expect(configuration.status).to.equal(BTClientApplePayStatusOff);
        });

        it(@"has status off when argument is 'off'", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@"off"];
            expect(configuration.status).to.equal(BTClientApplePayStatusOff);
        });

        it(@"has status mock when argument is 'mock'", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@"mock"];
            expect(configuration.status).to.equal(BTClientApplePayStatusMock);
        });

        it(@"mocks merchant ID with has a non-nil value when argument is 'mock'", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@"mock"];
            expect(configuration.merchantId).notTo.beNil();
        });

        it(@"has status production when argument is 'production'", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@"production"];
            expect(configuration.status).to.equal(BTClientApplePayStatusProduction);
        });

        it(@"has a nil merchant ID when argument is 'production'", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:@"production"];
            expect(configuration.merchantId).to.beNil();
        });

    });

    context(@"when argument is nil", ^{
        it(@"is initialized with status off", ^{
            BTClientApplePayConfiguration *configuration = [[BTClientApplePayConfiguration alloc] initWithConfigurationObject:nil];
            expect(configuration.status).to.equal(BTClientApplePayStatusOff);
        });
    });

});

SpecEnd
