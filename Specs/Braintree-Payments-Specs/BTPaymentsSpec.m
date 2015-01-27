@import PassKit;
@import AddressBook;

#import "BTPaymentProvider.h"
#import "BTPaymentApplePayProvider_Internal.h"
#import "BTMockApplePayPaymentAuthorizationViewController.h"

#import "BTClient_Internal.h"
#import "BTClient+BTPayPal.h"

#import "BTPayPalAppSwitchHandler.h"
#import "BTVenmoAppSwitchHandler.h"

@interface BTPaymentProvider () <PKPaymentAuthorizationViewControllerDelegate>
@end

SpecBegin(BTPaymentProvider)

__block id client;
__block id delegate;

beforeEach(^{
    client = [OCMockObject mockForClass:[BTClient class]];
    [[client stub] btPayPal_preparePayPalMobileWithError:(NSError * __autoreleasing *)[OCMArg anyPointer]];
    [[client stub] postAnalyticsEvent:OCMOCK_ANY];
    [[[client stub] andReturnValue:@YES] btPayPal_isPayPalEnabled];

    delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];
});

afterEach(^{
    [client verify];
    [client stopMocking];

    [delegate verify];
    [delegate stopMocking];
});

describe(@"createPaymentMethod:", ^{

    __block BTPaymentProviderType providerType;
    __block BTPaymentProvider *provider;

    beforeEach(^{
        provider = [[BTPaymentProvider alloc] initWithClient:client];
        provider.client = client;
        provider.delegate = delegate;
    });

    context(@"when type is BTPaymentProviderTypeApplePay", ^{
        __block id applePayProvider;

        beforeEach(^{
            applePayProvider = [OCMockObject mockForClass:[BTPaymentApplePayProvider class]];
            [[[applePayProvider stub] andReturn:applePayProvider] alloc];
            __unused id _ = [[[applePayProvider stub] andReturn:applePayProvider] initWithClient:OCMOCK_ANY];
            [[applePayProvider stub] setDelegate:OCMOCK_ANY];
        });

        it(@"calls authorizeApplePay if options includes BTPaymentAuthorizationOptionMechanismViewController", ^{
            [[applePayProvider expect] authorizeApplePay];
            [provider createPaymentMethod:BTPaymentProviderTypeApplePay options:BTPaymentAuthorizationOptionMechanismViewController];
        });

        it(@"calls delegate didFailWithError: if options are 0", ^{
            [[delegate expect] paymentMethodCreator:provider didFailWithError:[OCMArg checkWithBlock:^BOOL(id error) {
                expect([error domain]).to.equal(BTPaymentProviderErrorDomain);
                expect([error code]).to.equal(BTPaymentProviderErrorOptionNotSupported);
                return YES;
            }]];
            [provider createPaymentMethod:BTPaymentProviderTypeApplePay options:0];
        });

        if ([PKPaymentAuthorizationViewController class]) {
            it(@"passes payment request configurations straight through to Apple Pay provider", ^{
                NSArray *supportedNetworks = @[ PKPaymentNetworkVisa, PKPaymentNetworkMasterCard ];
                NSArray *paymentSummaryItems = @[ [PKPaymentSummaryItem summaryItemWithLabel:@"Company" amount:[NSDecimalNumber decimalNumberWithString:@"1"]] ];
                NSArray *shippingMethods = @[ [PKPaymentSummaryItem summaryItemWithLabel:@"Shipping" amount:[NSDecimalNumber decimalNumberWithString:@"1"]] ];
                ABRecordRef shippingAddress = ABPersonCreate();
                ABRecordRef billingAddress = ABPersonCreate();

                [[applePayProvider expect] setPaymentSummaryItems:paymentSummaryItems];
                [[applePayProvider expect] setRequiredBillingAddressFields:PKAddressFieldAll];
                [[applePayProvider expect] setRequiredShippingAddressFields:PKAddressFieldAll];
                [[applePayProvider expect] setBillingAddress:billingAddress];
                [[applePayProvider expect] setShippingAddress:shippingAddress];
                [[applePayProvider expect] setShippingMethods:shippingMethods];
                [[applePayProvider expect] setSupportedNetworks:supportedNetworks];

                [provider setPaymentSummaryItems:paymentSummaryItems];
                [provider setRequiredBillingAddressFields:PKAddressFieldAll];
                [provider setRequiredShippingAddressFields:PKAddressFieldAll];
                [provider setBillingAddress:billingAddress];
                [provider setShippingAddress:shippingAddress];
                [provider setShippingMethods:shippingMethods];
                [provider setSupportedNetworks:supportedNetworks];

                [applePayProvider verify];
                
                CFRelease(shippingAddress);
                CFRelease(billingAddress);
            });
        }
    });

    context(@"when type is BTPaymentProviderTypePayPal", ^{

        __block id payPalAppSwitchHandler;

        beforeEach(^{
            providerType = BTPaymentProviderTypePayPal;

            payPalAppSwitchHandler = [OCMockObject mockForClass:[BTPayPalAppSwitchHandler class]];
            [[[payPalAppSwitchHandler stub] andReturn:payPalAppSwitchHandler] sharedHandler];
        });

        afterEach(^{
            [payPalAppSwitchHandler verify];
            [payPalAppSwitchHandler stopMocking];
        });

        context(@"and app switch is available", ^{

            beforeEach(^{
                [[[payPalAppSwitchHandler stub] andReturnValue:@YES] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY error:(NSError *__autoreleasing *)[OCMArg anyPointer]];
            });

            it(@"invokes an app switch delegate method", ^{
                [[delegate expect] paymentMethodCreatorWillPerformAppSwitch:provider];
                provider.delegate = delegate;
                [provider createPaymentMethod:BTPaymentProviderTypePayPal];
            });
        });

        context(@"and app switch is unavailable", ^{

            beforeEach(^{
                [[[payPalAppSwitchHandler stub] andReturnValue:@NO] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY error:(NSError *__autoreleasing *)[OCMArg anyPointer]];
            });

            it(@"returns YES and invokes view controller delegate method", ^{
                [[delegate expect] paymentMethodCreator:provider requestsPresentationOfViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                    return [obj isKindOfClass:[UIViewController class]];
                }]];
                provider.delegate = delegate;

                [provider createPaymentMethod:BTPaymentProviderTypePayPal];
            });
        });
    });


    context(@"when type is BTPaymentProviderTypeVenmo", ^{

        __block id venmoAppSwitchHandler;

        beforeEach(^{
            venmoAppSwitchHandler = [OCMockObject mockForClass:[BTVenmoAppSwitchHandler class]];
            [[[venmoAppSwitchHandler stub] andReturn:venmoAppSwitchHandler] sharedHandler];

            provider.delegate = delegate;
        });

        context(@"and app switch is available", ^{

            beforeEach(^{
                [[[venmoAppSwitchHandler stub] andReturnValue:@YES] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY error:(NSError *__autoreleasing *)[OCMArg anyPointer]];
            });

            it(@"invokes an app switch delegate method", ^{
                [[delegate expect] paymentMethodCreatorWillPerformAppSwitch:provider];
                [provider createPaymentMethod:BTPaymentProviderTypeVenmo];
            });
        });

        context(@"and app switch is unavailable", ^{

            beforeEach(^{
                [[[venmoAppSwitchHandler stub] andReturnValue:@NO] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY error:(NSError *__autoreleasing *)[OCMArg anyPointer]];
            });


            it(@"returns NO and does not invoke a willAppSwitch delegate method", ^{
                [[delegate expect] paymentMethodCreator:provider didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
                    if ([obj isKindOfClass:[NSError class]]) {
                        NSError *error = (NSError *)obj;
                        expect(error.domain).to.equal(BTPaymentProviderErrorDomain);
                        expect(error.code).to.equal(BTPaymentProviderErrorUnknown);
                        return YES;
                    }
                    return NO;
                }]];
                [provider createPaymentMethod:BTPaymentProviderTypeVenmo];
            });
        });
    });
});

SpecEnd
