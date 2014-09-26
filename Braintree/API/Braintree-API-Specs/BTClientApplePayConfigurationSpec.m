#import "BTClientDeprecatedApplePayConfiguration.h"
#import "BTLogger_Internal.h"

SpecBegin(BTClientDeprecatedApplePayConfiguration)

describe(@"initWithConfigurationObject:", ^{

    context(@"when argument is a dictionary", ^{
        it(@"is initialized", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@{}];
            expect(configuration.status).to.equal(BTClientApplePayStatusOff);
        });

        it(@"has status off when status is 'off'", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@{@"status": @"off"}];
            expect(configuration.status).to.equal(BTClientApplePayStatusOff);
        });

        it(@"has status off when status is 'I AM ON'", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@{@"status": @"i am off"}];
            expect(configuration.status).to.equal(BTClientApplePayStatusOff);
        });

        it(@"has status mock when status is 'mock'", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@{@"status": @"mock"}];
            expect(configuration.status).to.equal(BTClientApplePayStatusMock);
        });

        it(@"has status production when status is 'production'", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@{@"status": @"production"}];
            expect(configuration.status).to.equal(BTClientApplePayStatusProduction);
        });

        it(@"does not have a merchant id if no merchant id key is present", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@{}];
            expect(configuration.merchantId).to.beNil();
        });

        it(@"has a merchant id if a merchant id key is present", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@{@"merchantId": @"1234"}];
            expect(configuration.merchantId).to.equal(@"1234");
        });

        it(@"logs a warning", ^{
            id mockLogger = [OCMockObject mockForClass:[BTLogger class]];
            [[[mockLogger stub] andReturn:mockLogger] sharedLogger];
            [[mockLogger stub] info:OCMOCK_ANY];
            [[mockLogger expect] warning:OCMOCK_ANY];
            __unused id _ = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@{}];
            [mockLogger verify];
            [mockLogger stopMocking];
        });

    });

    context(@"when argument is a string", ^{
        it(@"has status off when argument is 'I AM ON'", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@"I AM ON"];
            expect(configuration.status).to.equal(BTClientApplePayStatusOff);
        });

        it(@"has status off when argument is 'off'", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@"off"];
            expect(configuration.status).to.equal(BTClientApplePayStatusOff);
        });

        it(@"has status mock when argument is 'mock'", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@"mock"];
            expect(configuration.status).to.equal(BTClientApplePayStatusMock);
        });

        it(@"mocks merchant ID with has a non-nil value when argument is 'mock'", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@"mock"];
            expect(configuration.merchantId).notTo.beNil();
        });

        it(@"has status production when argument is 'production'", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@"production"];
            expect(configuration.status).to.equal(BTClientApplePayStatusProduction);
        });

        it(@"has a nil merchant ID when argument is 'production'", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@"production"];
            expect(configuration.merchantId).to.beNil();
        });

        it(@"logs a warning", ^{
            id mockLogger = [OCMockObject mockForClass:[BTLogger class]];
            [[[mockLogger stub] andReturn:mockLogger] sharedLogger];
            [[mockLogger stub] info:OCMOCK_ANY];
            [[mockLogger expect] warning:OCMOCK_ANY];
            __unused id _ = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:@"mock"];
            [mockLogger verify];
            [mockLogger stopMocking];
        });
    });

    context(@"when argument is nil", ^{
        it(@"is initialized with status off", ^{
            BTClientDeprecatedApplePayConfiguration *configuration = [[BTClientDeprecatedApplePayConfiguration alloc] initWithConfigurationObject:nil];
            expect(configuration.status).to.equal(BTClientApplePayStatusOff);
        });
    });

});

SpecEnd
