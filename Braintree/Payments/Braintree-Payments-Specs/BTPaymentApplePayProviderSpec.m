#import "BTPaymentApplePayProvider_Internal.h"
#import "BTClient_Internal.h"
#import "BTMockApplePayPaymentAuthorizationViewController.h"

@import PassKit;

SpecBegin(BTPaymentApplePayProvider)

describe(@"canAuthorizeApplePayPayment", ^{
    BTPaymentApplePayProvider *(^testApplePayProvider)(BOOL isSimulator, BTClientApplePayStatusType applePayStatus, BOOL paymentAuthorizationViewControllerAvailable);

    testApplePayProvider = ^BTPaymentApplePayProvider *(BOOL isSimulator, BTClientApplePayStatusType applePayStatus, BOOL paymentAuthorizationViewControllerAvailable){
        id mockClient = [OCMockObject mockForClass:[BTClient class]];
        BTPaymentApplePayProvider *applePayProvider = [[BTPaymentApplePayProvider alloc] initWithClient:mockClient];

        id fakeConfiguration = [OCMockObject mockForClass:[BTClientApplePayConfiguration class]];
        id mockApplePayPayment = [OCMockObject partialMockForObject:applePayProvider];

        [[[mockApplePayPayment stub] andReturnValue:OCMOCK_VALUE(isSimulator)] isSimulator];
        [[[mockApplePayPayment stub] andReturnValue:OCMOCK_VALUE(paymentAuthorizationViewControllerAvailable)] paymentAuthorizationViewControllerCanMakePayments];

        [[[fakeConfiguration stub] andReturnValue:OCMOCK_VALUE(applePayStatus)] status];
        [[[fakeConfiguration stub] andReturn:@"a merchant id"] merchantId];
        [[[mockClient stub] andReturn:fakeConfiguration] applePayConfiguration];

        return applePayProvider;
    };

    BOOL (^testApplePayProviderCanAuthorizeApplePayPayment)(BTClientApplePayStatusType applePayStatus, BOOL paymentAuthorizationViewControllerAvailable);

    testApplePayProviderCanAuthorizeApplePayPayment = ^BOOL(BTClientApplePayStatusType applePayStatus, BOOL paymentAuthorizationViewControllerAvailable){
        return [testApplePayProvider(YES, applePayStatus, paymentAuthorizationViewControllerAvailable) canAuthorizeApplePayPayment];
    };

    describe(@"returns YES", ^{
        it(@"in production and mock when available", ^{
            expect(testApplePayProviderCanAuthorizeApplePayPayment(BTClientApplePayStatusProduction, YES)).to.beTruthy();
            expect(testApplePayProviderCanAuthorizeApplePayPayment(BTClientApplePayStatusMock, YES)).to.beTruthy();
        });
    });

    describe(@"returns NO when", ^{
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

        id fakeConfiguration = [OCMockObject mockForClass:[BTClientApplePayConfiguration class]];
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

        it(@"returns YES when BTMockApplePayPaymentAuthorizationViewController can make payments", ^{
            BTPaymentApplePayProvider *provider = testApplePayProvider(YES);
            id mockApplePayPaymentAuthorizationViewController = [OCMockObject mockForClass:[BTMockApplePayPaymentAuthorizationViewController class]];
            [[[[mockApplePayPaymentAuthorizationViewController stub] andReturnValue:OCMOCK_VALUE(YES)] classMethod] canMakePayments];

            expect([provider paymentAuthorizationViewControllerCanMakePayments]).to.beTruthy();
        });
    });

    describe(@"on a real device", ^{
        it(@"returns NO when PKPaymentAuthorizationViewController cannot make payments", ^{
            BTPaymentApplePayProvider *provider = testApplePayProvider(NO);
            id mockApplePayPaymentAuthorizationViewController = [OCMockObject mockForClass:[PKPaymentAuthorizationViewController class]];
            [[[[mockApplePayPaymentAuthorizationViewController stub] andReturnValue:OCMOCK_VALUE(NO)] classMethod] canMakePayments];
            expect([provider paymentAuthorizationViewControllerCanMakePayments]).to.beFalsy();
        });

        it(@"returns YES when PKPaymentAuthorizationViewController can make payments", ^{
            BTPaymentApplePayProvider *provider = testApplePayProvider(NO);
            id mockApplePayPaymentAuthorizationViewController = [OCMockObject mockForClass:[PKPaymentAuthorizationViewController class]];
            [[[[mockApplePayPaymentAuthorizationViewController stub] andReturnValue:OCMOCK_VALUE(YES)] classMethod] canMakePayments];

            expect([provider paymentAuthorizationViewControllerCanMakePayments]).to.beTruthy();
        });
    });
});

describe(@"authorizeApplePay", ^{
    BTPaymentApplePayProvider *(^testApplePayProvider)(BOOL isSimulator, BOOL paymentAuthorizationViewControllerAvailable);

    testApplePayProvider = ^BTPaymentApplePayProvider *(BOOL isSimulator, BOOL paymentAuthorizationViewControllerAvailable){
        id mockClient = [OCMockObject mockForClass:[BTClient class]];
        BTPaymentApplePayProvider *applePayProvider = [[BTPaymentApplePayProvider alloc] initWithClient:mockClient];

        id fakeConfiguration = [OCMockObject mockForClass:[BTClientApplePayConfiguration class]];
        id mockApplePayPayment = [OCMockObject partialMockForObject:applePayProvider];

        [[[mockApplePayPayment stub] andReturnValue:OCMOCK_VALUE(isSimulator)] isSimulator];
        [[[mockApplePayPayment stub] andReturnValue:OCMOCK_VALUE(paymentAuthorizationViewControllerAvailable)] paymentAuthorizationViewControllerCanMakePayments];

        [[[fakeConfiguration stub] andReturnValue:OCMOCK_VALUE(BTClientApplePayStatusProduction)] status];
        [[[fakeConfiguration stub] andReturn:@"a merchant id"] merchantId];
        [[[mockClient stub] andReturn:fakeConfiguration] applePayConfiguration];

        return applePayProvider;
    };

    describe(@"on a simulator", ^{
        it(@"presents a mock Apple Pay view controller", ^{
            OCMockObject *delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];

            BTPaymentApplePayProvider *provider = testApplePayProvider(YES, YES);
            provider.delegate = (id<BTPaymentMethodCreationDelegate>)delegate;

            [[delegate expect] paymentMethodCreator:provider requestsPresentationOfViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                return [obj isKindOfClass:[BTMockApplePayPaymentAuthorizationViewController class]];
            }]];

            [provider authorizeApplePay];

            [delegate verify];
        });
    });

    describe(@"on a supported device", ^{
        it(@"presents the Apple Pay view controller", ^{
            OCMockObject *delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];

            BTPaymentApplePayProvider *provider = testApplePayProvider(NO, YES);
            provider.delegate = (id<BTPaymentMethodCreationDelegate>)delegate;

            [[delegate expect] paymentMethodCreator:provider requestsPresentationOfViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                return [obj isKindOfClass:[PKPaymentAuthorizationViewController class]];
            }]];

            [provider authorizeApplePay];

            [delegate verify];
        });
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
