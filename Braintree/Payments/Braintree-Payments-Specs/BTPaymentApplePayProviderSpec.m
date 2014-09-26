#import "BTPaymentApplePayProvider_Internal.h"
#import "BTClient_Internal.h"
#import "BTMockApplePayPaymentAuthorizationViewController.h"
#import "BTPaymentProviderErrors.h"
#import "BTClientDeprecatedApplePayConfiguration.h"

@import PassKit;

SpecBegin(BTPaymentApplePayProvider)

describe(@"canAuthorizeApplePayPayment", ^{
    BTPaymentApplePayProvider *(^testApplePayProvider)(BOOL isSimulator, BTClientApplePayStatus applePayStatus, BOOL paymentAuthorizationViewControllerAvailable);

    testApplePayProvider = ^BTPaymentApplePayProvider *(BOOL isSimulator, BTClientApplePayStatus applePayStatus, BOOL paymentAuthorizationViewControllerAvailable){
        id mockClient = [OCMockObject mockForClass:[BTClient class]];
        BTPaymentApplePayProvider *applePayProvider = [[BTPaymentApplePayProvider alloc] initWithClient:mockClient];

        id fakeConfiguration = [OCMockObject mockForClass:[BTClientDeprecatedApplePayConfiguration class]];
        id mockApplePayPayment = [OCMockObject partialMockForObject:applePayProvider];

        [[[mockApplePayPayment stub] andReturnValue:OCMOCK_VALUE(isSimulator)] isSimulator];
        [[[mockApplePayPayment stub] andReturnValue:OCMOCK_VALUE(paymentAuthorizationViewControllerAvailable)] paymentAuthorizationViewControllerCanMakePayments];

        [[[fakeConfiguration stub] andReturnValue:OCMOCK_VALUE(applePayStatus)] status];
        [[[fakeConfiguration stub] andReturn:@"a merchant id"] merchantId];
        [[[mockClient stub] andReturn:fakeConfiguration] applePayConfiguration];

        return applePayProvider;
    };

    BOOL (^testApplePayProviderCanAuthorizeApplePayPayment)(BTClientApplePayStatus applePayStatus, BOOL paymentAuthorizationViewControllerAvailable);

    testApplePayProviderCanAuthorizeApplePayPayment = ^BOOL(BTClientApplePayStatus applePayStatus, BOOL paymentAuthorizationViewControllerAvailable){
        return [testApplePayProvider(YES, applePayStatus, paymentAuthorizationViewControllerAvailable) canAuthorizeApplePayPayment];
    };

    if ([PKPaymentAuthorizationViewController class]) {
        it(@"returns YES in production and mock when Apple Pay is available", ^{
            expect(testApplePayProviderCanAuthorizeApplePayPayment(BTClientApplePayStatusProduction, YES)).to.beTruthy();
            expect(testApplePayProviderCanAuthorizeApplePayPayment(BTClientApplePayStatusMock, YES)).to.beTruthy();
        });
    }

    describe(@"returns NO when", ^{
        if (![PKPaymentAuthorizationViewController class]) {
            it(@"Apple Pay is not available", ^{
                expect(testApplePayProviderCanAuthorizeApplePayPayment(BTClientApplePayStatusProduction, YES)).to.beFalsy();
                expect(testApplePayProviderCanAuthorizeApplePayPayment(BTClientApplePayStatusMock, YES)).to.beFalsy();
            });
        }

        it(@"the client token contains Apple Pay status off", ^{
            expect(testApplePayProviderCanAuthorizeApplePayPayment(BTClientApplePayStatusOff, YES)).to.beFalsy();
            expect(testApplePayProviderCanAuthorizeApplePayPayment(BTClientApplePayStatusOff, NO)).to.beFalsy();
        });

        it(@"when canMakePayments is false", ^{
            expect(testApplePayProviderCanAuthorizeApplePayPayment(BTClientApplePayStatusProduction, NO)).to.beFalsy();
            expect(testApplePayProviderCanAuthorizeApplePayPayment(BTClientApplePayStatusMock, NO)).to.beFalsy();
        });
    });
});

describe(@"paymentAuthorizationViewControllerAvailable", ^{
    BTPaymentApplePayProvider *(^testApplePayProvider)(BOOL isSimulator);

    testApplePayProvider = ^BTPaymentApplePayProvider *(BOOL isSimulator){
        id mockClient = [OCMockObject mockForClass:[BTClient class]];
        BTPaymentApplePayProvider *applePayProvider = [[BTPaymentApplePayProvider alloc] initWithClient:mockClient];

        id fakeConfiguration = [OCMockObject mockForClass:[BTClientDeprecatedApplePayConfiguration class]];
        id mockApplePayPayment = [OCMockObject partialMockForObject:applePayProvider];

        [[[mockApplePayPayment stub] andReturnValue:OCMOCK_VALUE(isSimulator)] isSimulator];

        [[[fakeConfiguration stub] andReturnValue:OCMOCK_VALUE(BTClientApplePayStatusProduction)] status];
        [[[fakeConfiguration stub] andReturn:@"a merchant id"] merchantId];
        [[[mockClient stub] andReturn:fakeConfiguration] applePayConfiguration];

        return applePayProvider;
    };

    describe(@"on the simulator", ^{
        it(@"returns NO when BTMockApplePayPaymentAuthorizationViewController cannot make payments", ^{
            BTPaymentApplePayProvider *provider = testApplePayProvider(YES);
            id mockApplePayPaymentAuthorizationViewController = [OCMockObject mockForClass:[BTMockApplePayPaymentAuthorizationViewController class]];
            [[[[mockApplePayPaymentAuthorizationViewController stub] andReturnValue:OCMOCK_VALUE(NO)] classMethod] canMakePayments];
            expect([provider paymentAuthorizationViewControllerCanMakePayments]).to.beFalsy();
        });

        if ([PKPaymentAuthorizationViewController class]) {
            it(@"returns YES when BTMockApplePayPaymentAuthorizationViewController can make payments and Apple Pay is supported", ^{
                BTPaymentApplePayProvider *provider = testApplePayProvider(YES);
                id mockApplePayPaymentAuthorizationViewController = [OCMockObject mockForClass:[BTMockApplePayPaymentAuthorizationViewController class]];
                [[[[mockApplePayPaymentAuthorizationViewController stub] andReturnValue:OCMOCK_VALUE(YES)] classMethod] canMakePayments];

                expect([provider paymentAuthorizationViewControllerCanMakePayments]).to.beTruthy();
            });
        } else {
            it(@"returns NO when Apple Pay is not supported", ^{
                BTPaymentApplePayProvider *provider = testApplePayProvider(YES);
                expect([provider paymentAuthorizationViewControllerCanMakePayments]).to.beFalsy();
            });
        }
    });

    describe(@"on a real device", ^{
        if ([PKPaymentAuthorizationViewController class]) {

            it(@"returns NO when PKPaymentAuthorizationViewController cannot make payments even if Apple Pay is supported", ^{
                BTPaymentApplePayProvider *provider = testApplePayProvider(NO);
                id mockApplePayPaymentAuthorizationViewController = [OCMockObject mockForClass:[PKPaymentAuthorizationViewController class]];
                [[[[mockApplePayPaymentAuthorizationViewController stub] andReturnValue:OCMOCK_VALUE(NO)] classMethod] canMakePayments];
                expect([provider paymentAuthorizationViewControllerCanMakePayments]).to.beFalsy();
            });

            it(@"returns YES when PKPaymentAuthorizationViewController can make payments and Apple Pay is supported", ^{
                BTPaymentApplePayProvider *provider = testApplePayProvider(NO);
                id mockApplePayPaymentAuthorizationViewController = [OCMockObject mockForClass:[PKPaymentAuthorizationViewController class]];
                [[[[mockApplePayPaymentAuthorizationViewController stub] andReturnValue:OCMOCK_VALUE(YES)] classMethod] canMakePayments];

                expect([provider paymentAuthorizationViewControllerCanMakePayments]).to.beTruthy();
            });
        } else {
            it(@"returns NO when Apple Pay is not supported", ^{
                BTPaymentApplePayProvider *provider = testApplePayProvider(NO);
                expect([provider paymentAuthorizationViewControllerCanMakePayments]).to.beFalsy();
            });

        }
    });
});

describe(@"authorizeApplePay", ^{
    BTPaymentApplePayProvider *(^testApplePayProvider)(BOOL isSimulator, BOOL paymentAuthorizationViewControllerAvailable);

    testApplePayProvider = ^BTPaymentApplePayProvider *(BOOL isSimulator, BOOL paymentAuthorizationViewControllerAvailable){
        id mockClient = [OCMockObject mockForClass:[BTClient class]];
        BTPaymentApplePayProvider *applePayProvider = [[BTPaymentApplePayProvider alloc] initWithClient:mockClient];

        id fakeConfiguration = [OCMockObject mockForClass:[BTClientDeprecatedApplePayConfiguration class]];
        id mockApplePayPayment = [OCMockObject partialMockForObject:applePayProvider];

        [[[mockApplePayPayment stub] andReturnValue:OCMOCK_VALUE(isSimulator)] isSimulator];
        [[[mockApplePayPayment stub] andReturnValue:OCMOCK_VALUE(paymentAuthorizationViewControllerAvailable)] paymentAuthorizationViewControllerCanMakePayments];

        [[[fakeConfiguration stub] andReturnValue:OCMOCK_VALUE(BTClientApplePayStatusProduction)] status];
        [[[fakeConfiguration stub] andReturn:@"a merchant id"] merchantId];
        [[[mockClient stub] andReturn:fakeConfiguration] applePayConfiguration];

        return applePayProvider;
    };

    describe(@"on a simulator", ^{
        if ([PKPaymentAuthorizationViewController class]) {
            it(@"presents a mock Apple Pay view controller if Apple Pay is supported", ^{
                OCMockObject *delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];

                BTPaymentApplePayProvider *provider = testApplePayProvider(YES, YES);
                provider.delegate = (id<BTPaymentMethodCreationDelegate>)delegate;

                [[delegate expect] paymentMethodCreator:provider requestsPresentationOfViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                    return [obj isKindOfClass:[BTMockApplePayPaymentAuthorizationViewController class]];
                }]];

                [provider authorizeApplePay];

                [delegate verify];
            });
        } else {
            it(@"fails when Apple Pay is not enabled", ^{
                OCMockObject *delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];

                BTPaymentApplePayProvider *provider = testApplePayProvider(NO, YES);
                provider.delegate = (id<BTPaymentMethodCreationDelegate>)delegate;

                [[delegate expect] paymentMethodCreator:provider didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
                    NSError *error = (NSError *)obj;
                    expect(error.domain).to.equal(BTPaymentProviderErrorDomain);
                    expect(error.code).to.equal(BTPaymentProviderErrorOptionNotSupported);
                    return YES;
                }]];

                [provider authorizeApplePay];

                [delegate verify];
            });
        }
    });

    describe(@"on a supported device", ^{
        if ([PKPaymentAuthorizationViewController class]) {
            it(@"presents the Apple Pay view controller when Apple Pay is enabled", ^{
                OCMockObject *delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];

                BTPaymentApplePayProvider *provider = testApplePayProvider(NO, YES);
                provider.delegate = (id<BTPaymentMethodCreationDelegate>)delegate;

                [[delegate expect] paymentMethodCreator:provider requestsPresentationOfViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                    return [obj isKindOfClass:[PKPaymentAuthorizationViewController class]];
                }]];

                [provider authorizeApplePay];

                [delegate verify];
            });
        } else {
            it(@"fails when Apple Pay is not enabled", ^{
                OCMockObject *delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];

                BTPaymentApplePayProvider *provider = testApplePayProvider(NO, YES);
                provider.delegate = (id<BTPaymentMethodCreationDelegate>)delegate;

                [[delegate expect] paymentMethodCreator:provider didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
                    NSError *error = (NSError *)obj;
                    expect(error.domain).to.equal(BTPaymentProviderErrorDomain);
                    expect(error.code).to.equal(BTPaymentProviderErrorOptionNotSupported);
                    return YES;
                }]];

                [provider authorizeApplePay];

                [delegate verify];
            });
        }
    });

    describe(@"on an unsupported device", ^{
        it(@"fails to present a payment authorization view controller", ^{
            OCMockObject *delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];

            BTPaymentApplePayProvider *provider = testApplePayProvider(NO, NO);
            provider.delegate = (id<BTPaymentMethodCreationDelegate>)delegate;

            [[delegate expect] paymentMethodCreator:provider didFailWithError:[OCMArg any]];

            [provider authorizeApplePay];

            [delegate verify];
        });
    });


});

SpecEnd
