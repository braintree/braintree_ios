@import PassKit;
@import AddressBook;

#import "BTAppSwitch.h"
#import "BTPaymentProvider.h"
#import "BTPaymentApplePayProvider_Internal.h"
#import "BTMockApplePayPaymentAuthorizationViewController.h"

#import "BTClient_Internal.h"
#import "BTClient+BTPayPal.h"

#import "BTPayPalAppSwitchHandler.h"
#import "BTVenmoAppSwitchHandler.h"
#import "BTPayPalViewController.h"

#import "BTCoinbase.h"
#import "BTCoinbaseOAuth.h"

typedef void (^BTPaymentsSpecHelperBlock)(id, NSError *);

@interface BTPaymentsSpecHelper : NSObject <BTPaymentMethodCreationDelegate>
@end

@implementation BTPaymentsSpecHelper {
    BTPaymentsSpecHelperBlock _block;
}

+ (id)delegateWithErrorBlock:(BTPaymentsSpecHelperBlock)block {
    BTPaymentsSpecHelper *helper = [[self alloc] init];
    helper->_block = [block copy];
    return helper;
}

- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error {
    if (_block) { _block(sender, error); }
}

- (void)paymentMethodCreatorWillPerformAppSwitch:(id)sender {
    if (_block) { _block(sender, nil); }
}

- (void)paymentMethodCreator:(id)sender requestsPresentationOfViewController:(UIViewController *)viewController {
    if (_block) { _block(sender, nil); }
}

- (void)paymentMethodCreatorDidCancel:(id)sender {
    if (_block) { _block(sender, nil); }
}

- (void)paymentMethodCreator:(id)sender requestsDismissalOfViewController:(UIViewController *)viewController {
    if (_block) { _block(sender, nil); }
}

- (void)paymentMethodCreator:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    if (_block) { _block(sender, nil); }
}

- (void)paymentMethodCreatorWillProcess:(id)sender {
    if (_block) { _block(sender, nil); }
}

@end

@interface BTPaymentProvider () <PKPaymentAuthorizationViewControllerDelegate>
@end

SpecBegin(BTPaymentProvider)

__block BTPaymentProvider *provider;
__block id client;
__block id configuration;
__block id delegate;

beforeEach(^{
    configuration = [OCMockObject mockForClass:[BTConfiguration class]];

    client = [OCMockObject mockForClass:[BTClient class]];
    [[client stub] btPayPal_preparePayPalMobileWithError:(NSError * __autoreleasing *)[OCMArg anyPointer]];
    [[client stub] postAnalyticsEvent:OCMOCK_ANY];

    // Use `expect` because we change the value of `btPayPal_isPayPalEnabled` depending on the test.
    [[[client expect] andReturnValue:@YES] btPayPal_isPayPalEnabled];
    // Code within this `beforeEach` block will call `btPayPal_isPayPalEnabled` twice.
    [[[client expect] andReturnValue:@YES] btPayPal_isPayPalEnabled];

    [[[client stub] andReturn:configuration] configuration];

    delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];

    provider = [[BTPaymentProvider alloc] initWithClient:client];
    provider.client = client;
    provider.delegate = delegate;
});

afterEach(^{
    [client verify];
    [client stopMocking];

    [delegate verify];
    [delegate stopMocking];
});

describe(@"createPaymentMethod:", ^{
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
                PKContact *shippingContact = [[PKContact alloc] init];
                PKContact *billingContact = [[PKContact alloc] init];
                
                [[applePayProvider expect] setPaymentSummaryItems:paymentSummaryItems];
                [[applePayProvider expect] setRequiredBillingAddressFields:PKAddressFieldAll];
                [[applePayProvider expect] setRequiredShippingAddressFields:PKAddressFieldAll];
                [[applePayProvider expect] setBillingAddress:billingAddress];
                [[applePayProvider expect] setShippingAddress:shippingAddress];
                [[applePayProvider expect] setShippingMethods:shippingMethods];
                [[applePayProvider expect] setSupportedNetworks:supportedNetworks];
                [[applePayProvider expect] setShippingContact:shippingContact];
                [[applePayProvider expect] setBillingContact:billingContact];
                
                [provider setPaymentSummaryItems:paymentSummaryItems];
                [provider setRequiredBillingAddressFields:PKAddressFieldAll];
                [provider setRequiredShippingAddressFields:PKAddressFieldAll];
                [provider setBillingAddress:billingAddress];
                [provider setShippingAddress:shippingAddress];
                [provider setShippingMethods:shippingMethods];
                [provider setSupportedNetworks:supportedNetworks];
                [provider setBillingContact:billingContact];
                [provider setShippingContact:shippingContact];

                [applePayProvider verify];

                CFRelease(shippingAddress);
                CFRelease(billingAddress);
            });
        }
    });

    context(@"when type is BTPaymentProviderTypePayPal", ^{

        __block id payPalAppSwitchHandler;

        beforeEach(^{
            payPalAppSwitchHandler = [OCMockObject mockForClass:[BTPayPalAppSwitchHandler class]];
            [[BTAppSwitch sharedInstance] addAppSwitching:payPalAppSwitchHandler forApp:BTAppTypePayPal];
        });

        afterEach(^{
            [payPalAppSwitchHandler verify];
            [[BTAppSwitch sharedInstance] addAppSwitching:[BTPayPalAppSwitchHandler sharedHandler] forApp:BTAppTypePayPal];
        });

        context(@"and app switch is available", ^{

            beforeEach(^{
                [[[payPalAppSwitchHandler stub] andReturnValue:@YES] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY error:(NSError *__autoreleasing *)[OCMArg anyPointer]];
            });

            it(@"status is uninitialized", ^{
                expect([provider status]).to.equal(BTPaymentProviderStatusUninitialized);
            });

            it(@"invokes an app switch delegate method", ^{
                [[delegate expect] paymentMethodCreatorWillPerformAppSwitch:provider];
                provider.delegate = delegate;
                [provider createPaymentMethod:BTPaymentProviderTypePayPal];
                expect([provider status]).to.equal(BTPaymentProviderStatusInitialized);
            });

            it(@"invokes didcancel delegate method", ^{
                [[delegate expect] paymentMethodCreatorDidCancel:provider];
                provider.delegate = delegate;
                [(id<BTPaymentMethodCreationDelegate>)provider paymentMethodCreatorDidCancel:nil];
                expect([provider status]).to.equal(BTPaymentProviderStatusCanceled);
            });

            it(@"invokes error delegate method", ^{
                [[delegate expect] paymentMethodCreator:provider didFailWithError:nil];
                provider.delegate = delegate;
                [(id<BTPaymentMethodCreationDelegate>)provider paymentMethodCreator:provider didFailWithError:nil];
                expect([provider status]).to.equal(BTPaymentProviderStatusError);
            });

            it(@"invokes success delegate method", ^{
                [[delegate expect] paymentMethodCreator:provider didCreatePaymentMethod:nil];
                provider.delegate = delegate;
                [(id<BTPaymentMethodCreationDelegate>)provider paymentMethodCreator:provider didCreatePaymentMethod:nil];
                expect([provider status]).to.equal(BTPaymentProviderStatusSuccess);
            });

            it(@"invokes willprocess delegate method", ^{
                [[delegate expect] paymentMethodCreatorWillProcess:provider];
                provider.delegate = delegate;
                [(id<BTPaymentMethodCreationDelegate>)provider paymentMethodCreatorWillProcess:provider];
                expect([provider status]).to.equal(BTPaymentProviderStatusProcessing);
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

            it(@"provider has the right state and cancels view controller", ^{
                [[delegate expect] paymentMethodCreator:provider requestsPresentationOfViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                    return [obj isKindOfClass:[UIViewController class]];
                }]];
                [[delegate expect] paymentMethodCreatorDidCancel:[OCMArg isNotNil]];
                [[delegate expect] paymentMethodCreator:[OCMArg checkWithBlock:^BOOL(id obj) {
                    return [(BTPaymentProvider *)obj status] == BTPaymentProviderStatusCanceled;
                }]
                      requestsDismissalOfViewController:nil];
                provider.delegate = delegate;
                [provider createPaymentMethod:BTPaymentProviderTypePayPal];
                [(id<BTPayPalViewControllerDelegate>)provider payPalViewControllerDidCancel:nil];
            });
        });
    });


    context(@"when type is BTPaymentProviderTypeVenmo", ^{

        __block id venmoAppSwitchHandler;

        beforeEach(^{
            venmoAppSwitchHandler = [OCMockObject mockForClass:[BTVenmoAppSwitchHandler class]];
            [[BTAppSwitch sharedInstance] addAppSwitching:venmoAppSwitchHandler forApp:BTAppTypeVenmo];
            provider.delegate = delegate;
        });
        
        afterEach(^{
            [[BTAppSwitch sharedInstance] addAppSwitching:[BTVenmoAppSwitchHandler sharedHandler] forApp:BTAppTypeVenmo];
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

    context(@"when type is BTPaymentProviderTypeCoinbase", ^{
        __block id stubCoinbase;

        beforeEach(^{
            stubCoinbase = [OCMockObject mockForClass:[BTCoinbase class]];
            [[BTAppSwitch sharedInstance] addAppSwitching:stubCoinbase forApp:BTAppTypeCoinbase];
        });

        afterEach(^{
            [stubCoinbase verify];
            [[BTAppSwitch sharedInstance] addAppSwitching:[BTCoinbase sharedCoinbase] forApp:BTAppTypeCoinbase];
        });

        describe(@"create payment method with default options", ^{
            it(@"performs an app switch or browser switch to coinbase", ^{
                [[[stubCoinbase expect] andReturnValue:@(YES)] initiateAppSwitchWithClient:OCMOCK_ANY
                                                                                  delegate:OCMOCK_ANY
                                                                                     error:(NSError *__autoreleasing *)[OCMArg anyPointer]];

                [[delegate expect] paymentMethodCreatorWillPerformAppSwitch:provider];

                provider.delegate = delegate;
                
                [provider createPaymentMethod:BTPaymentProviderTypeCoinbase];
            });

            it(@"performs an app switch regardless of the payment authorization options", ^{
                [[[stubCoinbase expect] andReturnValue:@(YES)] initiateAppSwitchWithClient:OCMOCK_ANY
                                                                                  delegate:OCMOCK_ANY
                                                                                     error:(NSError *__autoreleasing *)[OCMArg anyPointer]];

                [[delegate expect] paymentMethodCreatorWillPerformAppSwitch:provider];

                provider.delegate = delegate;
                
                [provider createPaymentMethod:BTPaymentProviderTypeCoinbase options:BTPaymentAuthorizationOptionMechanismViewController];
            });

            it(@"returns the error when BTCoinbase returns an error", ^{
                NSError *error = [OCMockObject mockForClass:[NSError class]];
                id coinbaseInitiationExpectation = [stubCoinbase expect];
                [coinbaseInitiationExpectation andReturnValue:@(NO)];
                [coinbaseInitiationExpectation andDo:^(NSInvocation *invocation){
                    NSError *__autoreleasing*errorPtr;
                    [invocation getArgument:&errorPtr atIndex:4];
                    *errorPtr = error;
                }];
                [coinbaseInitiationExpectation initiateAppSwitchWithClient:OCMOCK_ANY
                                                                  delegate:OCMOCK_ANY
                                                                     error:(NSError *__autoreleasing *)[OCMArg anyPointer]];

                [[delegate expect] paymentMethodCreator:provider didFailWithError:error];

                provider.delegate = delegate;
                
                [provider createPaymentMethod:BTPaymentProviderTypeCoinbase];
            });

            describe(@"when Coinbase is not enabled", ^{
                __block NSError *initiationError;

                beforeEach(^{
                    id coinbaseInitiationExpectation = [stubCoinbase expect];
                    [coinbaseInitiationExpectation andReturnValue:@(NO)];
                    [coinbaseInitiationExpectation andDo:^(NSInvocation *invocation){
                        NSError *__autoreleasing*errorPtr;
                        [invocation getArgument:&errorPtr atIndex:4];
                        *errorPtr = initiationError;
                    }];
                    [coinbaseInitiationExpectation initiateAppSwitchWithClient:OCMOCK_ANY
                                                                      delegate:OCMOCK_ANY
                                                                         error:(NSError *__autoreleasing *)[OCMArg anyPointer]];
                    provider.delegate = delegate;
                });
                
                it(@"returns NO", ^{
                    [[delegate expect] paymentMethodCreator:provider didFailWithError:initiationError];
                    [[[configuration stub] andReturnValue:@(NO)] coinbaseEnabled];
                    
                    [provider createPaymentMethod:BTPaymentProviderTypeCoinbase];
                });
                
                it(@"returns NO even if the coinbase app is installed", ^{
                    [[delegate expect] paymentMethodCreator:provider didFailWithError:initiationError];
                    id coinbaseOAuth = [OCMockObject mockForClass:[BTCoinbaseOAuth class]];
                    [[[[coinbaseOAuth stub] classMethod] andReturnValue:@(YES)] isAppOAuthAuthenticationAvailable];
                    [[[configuration stub] andReturnValue:@(NO)] coinbaseEnabled];
                    
                    [provider createPaymentMethod:BTPaymentProviderTypeCoinbase];
                });
            });
            
            context(@"and app switch is available", ^{
                beforeEach(^{
                    [[[stubCoinbase stub] andReturnValue:@YES] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY error:(NSError *__autoreleasing *)[OCMArg anyPointer]];
                    [[[client stub] andReturnValue:@YES] hasConfiguration];
                });

                it(@"starts with uninitialized status", ^{
                    expect([provider status]).to.equal(BTPaymentProviderStatusUninitialized);
                });

                it(@"invokes an app switch delegate method", ^{
                    [[delegate expect] paymentMethodCreatorWillPerformAppSwitch:provider];
                    provider.delegate = delegate;
                    [provider createPaymentMethod:BTPaymentProviderTypeCoinbase];
                    expect([provider status]).to.equal(BTPaymentProviderStatusInitialized);
                });

                it(@"invokes didCancel delegate method", ^{
                    [[delegate expect] paymentMethodCreatorDidCancel:provider];
                    provider.delegate = delegate;
                    [(id<BTPaymentMethodCreationDelegate>)provider paymentMethodCreatorDidCancel:nil];
                    expect([provider status]).to.equal(BTPaymentProviderStatusCanceled);
                });

                it(@"invokes error delegate method", ^{
                    NSError *error = [OCMockObject mockForClass:[NSError class]];
                    [[delegate expect] paymentMethodCreator:provider didFailWithError:error];
                    provider.delegate = delegate;
                    [(id<BTPaymentMethodCreationDelegate>)provider paymentMethodCreator:provider didFailWithError:error];
                    expect([provider status]).to.equal(BTPaymentProviderStatusError);
                });

                it(@"invokes success delegate method", ^{
                    id paymentMethod = [OCMockObject mockForClass:[BTCoinbasePaymentMethod class]];
                    [[delegate expect] paymentMethodCreator:provider didCreatePaymentMethod:paymentMethod];
                    provider.delegate = delegate;
                    [(id<BTPaymentMethodCreationDelegate>)provider paymentMethodCreator:provider didCreatePaymentMethod:paymentMethod];
                    expect([provider status]).to.equal(BTPaymentProviderStatusSuccess);
                });

                it(@"invokes willProcess delegate method", ^{
                    [[delegate expect] paymentMethodCreatorWillProcess:provider];
                    provider.delegate = delegate;
                    [(id<BTPaymentMethodCreationDelegate>)provider paymentMethodCreatorWillProcess:provider];
                    expect([provider status]).to.equal(BTPaymentProviderStatusProcessing);
                });
            });
        });
    });
});

describe(@"canCreatePaymentMethodWithProviderType:", ^{
    context(@"paypal", ^{
        it(@"always returns YES when the client (token) enables paypal", ^{
            [[[client stub] andReturnValue:@YES] btPayPal_isPayPalEnabled];
            BOOL canCreatePayPal = [provider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypePayPal];
            expect(canCreatePayPal).to.beTruthy();
        });

        it(@"returns NO when the client (token) does not enable paypal", ^{
            [[[client expect] andReturnValue:@(NO)] btPayPal_isPayPalEnabled];
            BOOL canCreatePayPal = [provider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypePayPal];
            expect(canCreatePayPal).to.beFalsy();
        });
    });

    context(@"coinbase", ^{
        __block id coinbaseOAuth;

        beforeEach(^{
            coinbaseOAuth = [OCMockObject mockForClass:[BTCoinbaseOAuth class]];
        });

        context(@"with coinbase enabled", ^{
            it(@"returns YES when the coinbase app is installed", ^{
                [[[[coinbaseOAuth stub] classMethod] andReturnValue:@(YES)] isAppOAuthAuthenticationAvailable];
                [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];
                BOOL canCreateCoinbase = [provider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeCoinbase];
                expect(canCreateCoinbase).to.beTruthy();
            });

            it(@"still returns YES when coinbase app is NOT installed", ^{
                [[[[coinbaseOAuth stub] classMethod] andReturnValue:@(NO)] isAppOAuthAuthenticationAvailable];
                [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];
                BOOL canCreateCoinbase = [provider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeCoinbase];
                expect(canCreateCoinbase).to.beTruthy();
            });
        });

        context(@"with coinbase disabled", ^{
            it(@"returns NO", ^{
                [[[configuration stub] andReturnValue:@(NO)] coinbaseEnabled];
                BOOL canCreateCoinbase = [provider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeCoinbase];
                expect(canCreateCoinbase).to.beFalsy();
            });
            
            it(@"returns NO even if the coinbase app is installed", ^{
                [[[[coinbaseOAuth stub] classMethod] andReturnValue:@(YES)] isAppOAuthAuthenticationAvailable];
                [[[configuration stub] andReturnValue:@(NO)] coinbaseEnabled];
                BOOL canCreateCoinbase = [provider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeCoinbase];
                expect(canCreateCoinbase).to.beFalsy();
            });
        });
    });
});

SpecEnd
