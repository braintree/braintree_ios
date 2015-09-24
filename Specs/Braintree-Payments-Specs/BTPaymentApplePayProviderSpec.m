@import PassKit;
@import AddressBook;

#import "BTPaymentApplePayProvider_Internal.h"
#import "BTClient_Internal.h"
#import "BTMockApplePayPaymentAuthorizationViewController.h"
#import "BTPaymentProviderErrors.h"
#import "BTPaymentApplePayProvider.h"

SpecBegin(BTPaymentApplePayProvider)

describe(@"canAuthorizeApplePayPayment", ^{
    BTPaymentApplePayProvider *(^testApplePayProvider)(BOOL isSimulator, BTClientApplePayStatus applePayStatus, BOOL paymentAuthorizationViewControllerAvailable);

    testApplePayProvider = ^BTPaymentApplePayProvider *(BOOL isSimulator, BTClientApplePayStatus applePayStatus, BOOL paymentAuthorizationViewControllerAvailable){
        id mockClient = [OCMockObject mockForClass:[BTClient class]];
        [[mockClient stub] postAnalyticsEvent:OCMOCK_ANY];
        BTPaymentApplePayProvider *applePayProvider = [[BTPaymentApplePayProvider alloc] initWithClient:mockClient];

        if ([PKPaymentSummaryItem class]) {
            applePayProvider.paymentSummaryItems = @[ [PKPaymentSummaryItem summaryItemWithLabel:@"Label" amount:[NSDecimalNumber decimalNumberWithString:@"1"]]];
        }

        id mockApplePayPayment = [OCMockObject partialMockForObject:applePayProvider];
        [[[mockApplePayPayment stub] andReturnValue:OCMOCK_VALUE(isSimulator)] isSimulator];
        [[[mockApplePayPayment stub] andReturnValue:OCMOCK_VALUE(paymentAuthorizationViewControllerAvailable)] paymentAuthorizationViewControllerCanMakePayments];

        id mockConfiguration = [OCMockObject mockForClass:[BTConfiguration class]];
        if ([PKPaymentSummaryItem class]) {
            [[[mockConfiguration stub] andReturnValue:OCMOCK_VALUE(applePayStatus)] applePayStatus];
            [[[mockConfiguration stub] andReturn:@[ PKPaymentNetworkAmex,
                                                  PKPaymentNetworkVisa,
                                                  PKPaymentNetworkMasterCard ]] applePaySupportedNetworks];
        }
        [[[mockClient stub] andReturn:mockConfiguration] configuration];

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
        if (![PKPaymentRequest class]) {
            return nil;
        }

        id mockConfiguration  = [OCMockObject mockForClass:[BTConfiguration class]];
        [[[mockConfiguration stub] andReturnValue:OCMOCK_VALUE(BTClientApplePayStatusProduction)] applePayStatus];
        [[[mockConfiguration stub] andReturn:@[ PKPaymentNetworkAmex ]] applePaySupportedNetworks];
        [[[mockConfiguration stub] andReturn:@"a merchant"] applePayMerchantIdentifier];
        [[[mockConfiguration stub] andReturn:@"USD"] applePayCurrencyCode];
        [[[mockConfiguration stub] andReturn:@"US"] applePayCountryCode];


        id mockClient = [OCMockObject mockForClass:[BTClient class]];
        [[[mockClient stub] andReturn:mockConfiguration] configuration];
        [[mockClient stub] postAnalyticsEvent:OCMOCK_ANY];

        BTPaymentApplePayProvider *applePayProvider = [[BTPaymentApplePayProvider alloc] initWithClient:mockClient];

        id mockApplePayPayment = [OCMockObject partialMockForObject:applePayProvider];
        [[[mockApplePayPayment stub] andReturnValue:OCMOCK_VALUE(isSimulator)] isSimulator];

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
                [[[[mockApplePayPaymentAuthorizationViewController stub] andReturnValue:OCMOCK_VALUE(NO)] classMethod] canMakePaymentsUsingNetworks:OCMOCK_ANY];
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
    __block id mockApplePayPaymentProvider;

    testApplePayProvider = ^BTPaymentApplePayProvider *(BOOL isSimulator, BOOL paymentAuthorizationViewControllerAvailable){
        id mockClient = [OCMockObject mockForClass:[BTClient class]];
        [[mockClient stub] postAnalyticsEvent:OCMOCK_ANY];
        BTPaymentApplePayProvider *applePayProvider = [[BTPaymentApplePayProvider alloc] initWithClient:mockClient];

        mockApplePayPaymentProvider = [OCMockObject partialMockForObject:applePayProvider];
        [[[mockApplePayPaymentProvider stub] andReturnValue:OCMOCK_VALUE(isSimulator)] isSimulator];
        [[[mockApplePayPaymentProvider stub] andReturnValue:OCMOCK_VALUE(paymentAuthorizationViewControllerAvailable)] paymentAuthorizationViewControllerCanMakePayments];
        [[[mockApplePayPaymentProvider stub] andReturn:@[ [PKPaymentSummaryItem summaryItemWithLabel:@"Item" amount:[NSDecimalNumber decimalNumberWithString:@"1"]] ]] paymentSummaryItems];

        id mockConfiguration = [OCMockObject mockForClass:[BTConfiguration class]];
        [[[mockConfiguration stub] andReturnValue:OCMOCK_VALUE(BTClientApplePayStatusProduction)] applePayStatus];
        if ([PKPaymentRequest class]) {
            [[[mockConfiguration stub] andReturn:@"a merchant"] applePayMerchantIdentifier];
            [[[mockConfiguration stub] andReturn:@[ PKPaymentNetworkAmex ]] applePaySupportedNetworks];
            [[[mockConfiguration stub] andReturn:@"US"] applePayCountryCode];
            [[[mockConfiguration stub] andReturn:@"USD"] applePayCurrencyCode];
        }
        [[[mockClient stub] andReturn:mockConfiguration] configuration];

        return applePayProvider;
    };

    if ([PKPaymentAuthorizationViewController class]) {
        it(@"passes a configured PKPaymentRequest to Apple Pay", ^{
            waitUntil(^(DoneCallback done) {
                BTPaymentApplePayProvider *provider = testApplePayProvider(NO, YES);
                provider.delegate = [OCMockObject niceMockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];
                provider.paymentSummaryItems = @[ [PKPaymentSummaryItem summaryItemWithLabel:@"label" amount:[NSDecimalNumber decimalNumberWithString:@"1"]] ];
                provider.requiredBillingAddressFields = PKAddressFieldPostalAddress;
                provider.requiredShippingAddressFields = PKAddressFieldPostalAddress;
                PKShippingMethod *shippingMethod = [PKShippingMethod summaryItemWithLabel:@"Shipping Method" amount:[NSDecimalNumber decimalNumberWithString:@"2"]];
                shippingMethod.identifier = @"Shipping Method";
                provider.shippingMethods = @[ shippingMethod ];
                provider.supportedNetworks = @[ PKPaymentNetworkVisa ];
                ABRecordRef billingAddress = ABPersonCreate();
                provider.billingAddress = billingAddress;
                CFRelease(billingAddress);
                ABRecordRef shippingAddress = ABPersonCreate();
                provider.shippingAddress = shippingAddress;
                CFRelease(shippingAddress);
                provider.billingContact = [[PKContact alloc] init];
                provider.shippingContact = [[PKContact alloc] init];
                id checkPaymentRequestBlock = [OCMArg checkWithBlock:^BOOL(PKPaymentRequest *actualRequest) {
                    if ([actualRequest.paymentSummaryItems isEqualToArray:provider.paymentSummaryItems] &&
                        actualRequest.requiredShippingAddressFields == provider.requiredShippingAddressFields &&
                        actualRequest.requiredBillingAddressFields == provider.requiredBillingAddressFields &&
                        actualRequest.shippingAddress == provider.shippingAddress &&
                        actualRequest.billingAddress == provider.billingAddress &&
                        actualRequest.shippingContact == provider.shippingContact &&
                        actualRequest.billingContact == provider.billingContact) {
                        done();
                        return YES;
                    }
                    return NO;
                }];
                OCMStub([mockApplePayPaymentProvider paymentAuthorizationViewControllerWithPaymentRequest:checkPaymentRequestBlock]).andReturn(nil);
                
                [provider authorizeApplePay];
            });
        });


        it(@"the PKPaymentRequest favors values set on the provider over those from client configuration", ^{
            waitUntil(^(DoneCallback done) {
                BTPaymentApplePayProvider *provider = testApplePayProvider(NO, YES);
                provider.delegate = [OCMockObject niceMockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];
                provider.paymentSummaryItems = @[ [PKPaymentSummaryItem summaryItemWithLabel:@"label" amount:[NSDecimalNumber decimalNumberWithString:@"1"]] ];
                provider.supportedNetworks = @[ PKPaymentNetworkVisa ];
                id checkPaymentRequestBlock = [OCMArg checkWithBlock:^BOOL(PKPaymentRequest *actualRequest) {
                    if ([actualRequest.supportedNetworks isEqualToArray:provider.supportedNetworks]) {
                        done();
                        return YES;
                    }
                    return NO;
                }];
                OCMStub([mockApplePayPaymentProvider paymentAuthorizationViewControllerWithPaymentRequest:checkPaymentRequestBlock]).andReturn(nil);

                [provider authorizeApplePay];
            });
        });
    }

    describe(@"on a simulator", ^{
        if ([PKPaymentAuthorizationViewController class]) {
            it(@"presents a mock Apple Pay view controller if Apple Pay is supported", ^{
                OCMockObject *delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];

                BTPaymentApplePayProvider *provider = testApplePayProvider(YES, YES);
                provider.paymentSummaryItems = @[ [PKPaymentSummaryItem summaryItemWithLabel:@"Label" amount:[NSDecimalNumber decimalNumberWithString:@"1"]]];
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
                provider.paymentSummaryItems = @[ [PKPaymentSummaryItem summaryItemWithLabel:@"Label" amount:[NSDecimalNumber decimalNumberWithString:@"1"]]];
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
            if ([PKPaymentSummaryItem class]) {
                provider.paymentSummaryItems = @[ [PKPaymentSummaryItem summaryItemWithLabel:@"Label" amount:[NSDecimalNumber decimalNumberWithString:@"1"]]];
            }
            provider.delegate = (id<BTPaymentMethodCreationDelegate>)delegate;
            
            [[delegate expect] paymentMethodCreator:provider didFailWithError:[OCMArg any]];
            
            [provider authorizeApplePay];
            
            [delegate verify];
        });
    });
});

SpecEnd
