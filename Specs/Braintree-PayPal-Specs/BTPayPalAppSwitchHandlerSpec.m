#import "BTPayPalAppSwitchHandler_Internal.h"
#import "BTClient_Internal.h"
#import "PayPalOneTouchCore.h"
#import "PayPalOneTouchRequest.h"

@interface BTPayPalAppSwitchHandler (TestAdditions)
+ (void)resetSharedState;
@end

SpecBegin(BTPayPalAppSwitchHandler)

__block id client;
__block id clientToken;
__block id configuration;
__block id delegate;
__block id payPalTouch;

beforeEach(^{
    client = [OCMockObject mockForClass:[BTClient class]];
    configuration = [OCMockObject mockForClass:[BTConfiguration class]];
    clientToken = [OCMockObject mockForClass:[BTClientToken class]];
    delegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];
    payPalTouch = [OCMockObject mockForClass:[PayPalOneTouchCore class]];

    [[[client stub] andReturn:client] copyWithMetadata:OCMOCK_ANY];
    [[[client stub] andReturn:configuration] configuration];
    [[[client stub] andReturn:clientToken] clientToken];
});

afterEach(^{
    [client verify];
    [delegate verify];
    [payPalTouch verify];

    [(OCMockObject *)client stopMocking];
    [(OCMockObject *)delegate stopMocking];
    [(OCMockObject *)payPalTouch stopMocking];
});

describe(@"sharedHandler", ^{
    it(@"returns only one instance", ^{
        expect([BTPayPalAppSwitchHandler sharedHandler]).to.beIdenticalTo([BTPayPalAppSwitchHandler sharedHandler]);
    });
});


describe(@"initiatePayPalAuthWithClient:delegate:", ^{
    __block BTPayPalAppSwitchHandler *appSwitchHandler;

    beforeEach(^{
        appSwitchHandler = [[BTPayPalAppSwitchHandler alloc] init];
        appSwitchHandler.returnURLScheme = @"test.your.code";

        [[[[payPalTouch stub] andReturnValue:@YES] classMethod] doesApplicationSupportOneTouchCallbackURLScheme:OCMOCK_ANY];
    });

    context(@"with PayPal disabled", ^{
        it(@"returns error with code indicating PayPal is disabled", ^{
            [[[configuration stub] andReturnValue:@NO] payPalEnabled];
            [[client expect] postAnalyticsEvent:@"ios.paypal-otc.preflight.disabled"];
            NSError *error;
            BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate error:&error];
            expect(handled).to.beFalsy();
            expect(error.domain).to.equal(BTBraintreePayPalErrorDomain);
            expect(error.code).to.equal(BTPayPalErrorPayPalDisabled);
        });
    });

    context(@"with PayPal and PayPal Touch enabled", ^{
        beforeEach(^{
            [[[configuration stub] andReturnValue:@YES] payPalEnabled];
            appSwitchHandler.returnURLScheme = @"a-scheme";
        });

        context(@"with invalid parameters", ^{

            it(@"returns a BTAppSwitchErrorIntegrationReturnURLScheme error if returnURLScheme is nil", ^{
                appSwitchHandler.returnURLScheme = nil;
                [[client expect] postAnalyticsEvent:@"ios.paypal-otc.preflight.nil-return-url-scheme"];
                NSError *error;
                BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate error:&error];
                expect(handled).to.beFalsy();
                expect(error.domain).to.equal(BTAppSwitchErrorDomain);
                expect(error.code).to.equal(BTAppSwitchErrorIntegrationReturnURLScheme);
            });

            it(@"returns a BTAppSwitchErrorIntegrationInvalidParameters error with a nil delegate", ^{
                [[client expect] postAnalyticsEvent:@"ios.paypal-otc.preflight.nil-delegate"];
                NSError *error;
                BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:nil error:&error];
                expect(handled).to.beFalsy();
                expect(error.domain).to.equal(BTAppSwitchErrorDomain);
                expect(error.code).to.equal(BTAppSwitchErrorIntegrationInvalidParameters);
            });

            it(@"returns a BTAppSwitchErrorIntegrationInvalidParameters error with a nil client", ^{
                NSError *error;
                BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:nil delegate:delegate error:&error];
                expect(handled).to.beFalsy();
                expect(error.domain).to.equal(BTAppSwitchErrorDomain);
                expect(error.code).to.equal(BTAppSwitchErrorIntegrationInvalidParameters);
            });

        });

        context(@"PayPalOneTouchCore canAppSwitchForUrlScheme returns YES", ^{
            __block id authorizationRequestStub;

            beforeEach(^{
                [[[configuration stub] andReturnValue:@YES] payPalEnabled];
                [[[configuration stub] andReturn:@"some-client-id"] payPalClientId];
                [[[configuration stub] andReturn:@"http://example.com/privacy"] payPalPrivacyPolicyURL];
                [[[configuration stub] andReturn:@"http://example.com/tos"] payPalMerchantUserAgreementURL];
                [[[configuration stub] andReturn:@"Example Merchant"] payPalMerchantName];
                [[[configuration stub] andReturn:@"mock"] payPalEnvironment];
                [[[clientToken stub] andReturn:@"fake-client-token-string"] originalValue];
                [[[[payPalTouch stub] andReturnValue:@YES] classMethod] doesApplicationSupportOneTouchCallbackURLScheme:OCMOCK_ANY];

                authorizationRequestStub = [OCMockObject mockForClass:[PayPalOneTouchAuthorizationRequest class]];
                [[[[authorizationRequestStub stub] andReturn:authorizationRequestStub] classMethod] requestWithScopeValues:OCMOCK_ANY
                                                                                                    privacyURL:OCMOCK_ANY
                                                                                                  agreementURL:OCMOCK_ANY
                                                                                                      clientID:OCMOCK_ANY
                                                                                                   environment:OCMOCK_ANY
                                                                                             callbackURLScheme:OCMOCK_ANY];

                [[authorizationRequestStub stub] setAdditionalPayloadAttributes:OCMOCK_ANY];
                [[[authorizationRequestStub stub] andReturn:authorizationRequestStub] alloc];
            });

            it(@"returns a BTAppSwitchErrorFailed error if PayPalOneTouchCore fails to switch", ^{
                [[[authorizationRequestStub stub] andDo:^(NSInvocation *invocation) {
                    [invocation retainArguments];
                    PayPalOneTouchRequestCompletionBlock completionBlock;
                    [invocation getArgument:&completionBlock atIndex:2];
                    completionBlock(NO, PayPalOneTouchRequestTargetNone, nil);
                }] performWithCompletionBlock:OCMOCK_ANY];
                [[client expect] postAnalyticsEvent:@"ios.paypal-future-payments.none.initiate.failed"];

                NSError *error;
                BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate error:&error];

                expect(handled).to.beFalsy();
                expect(error.domain).to.equal(BTAppSwitchErrorDomain);
                expect(error.code).to.equal(BTAppSwitchErrorFailed);
            });

            it(@"error is nil when PayPalOneTouchCore can and does web browser switch", ^{
                [[[authorizationRequestStub stub] andDo:^(NSInvocation *invocation) {
                    [invocation retainArguments];
                    PayPalOneTouchRequestCompletionBlock completionBlock;
                    [invocation getArgument:&completionBlock atIndex:2];
                    completionBlock(YES, PayPalOneTouchRequestTargetBrowser, nil);
                }] performWithCompletionBlock:OCMOCK_ANY];
                [[client expect] postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.initiate.started"];

                NSError *error;
                BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate error:&error];

                expect(handled).to.beTruthy();
                expect(error).to.beNil();
            });
        });
    });
});

describe(@"handleReturnURL:", ^{

    __block BTPayPalAppSwitchHandler *appSwitchHandler;
    __block NSURL *sampleURL = [NSURL URLWithString:@"test.your.code://hello"];

    // NOTE: PayPalOneTouchCore does a case-sensitive comparison when verifying that the returnURLScheme is in .plist
    // App switch will fail if the capitalization here does not match the value in .plist:
    NSString *const goodReturnURLScheme = @"com.braintreepayments.Braintree-Demo.payments";
    
    NSString *const returnURLSchemeMissingFromPlist = @"com.braintreepayments.Braintree-Demo.other-suffix";
    //NSString *const invalidReturnURLScheme = @"test.your.code";
    
    beforeEach(^{
        [BTPayPalAppSwitchHandler resetSharedState];
        
        appSwitchHandler = [[BTPayPalAppSwitchHandler alloc] init];
        appSwitchHandler.returnURLScheme = goodReturnURLScheme;
        appSwitchHandler.delegate = delegate;
        appSwitchHandler.client = client;
    });

    it(@"does nothing when BTPayPalDriver has not been initialized", ^{
        [appSwitchHandler handleReturnURL:sampleURL];
    });
    
    it(@"does nothing when BTPayPalDriver has not been initialized, even if returnURLScheme is nil", ^{
        appSwitchHandler.returnURLScheme = nil;
        [appSwitchHandler handleReturnURL:sampleURL];
    });
    
    it(@"when url scheme is not found in .plist", ^{
        
        // Expected behavior:
        // PayPal OneTouchCoreSDK: callback URL scheme com.braintreepayments.braintree-demo.other-suffix is not found in .plist
        appSwitchHandler.returnURLScheme = returnURLSchemeMissingFromPlist;
        
        [[client expect] postAnalyticsEvent:@"ios.paypal-otc.preflight.invalid-return-url-scheme"];
        
        [[[configuration stub] andReturnValue:@YES] payPalEnabled];
        
        id authorizationRequestStub = [OCMockObject mockForClass:[PayPalOneTouchAuthorizationRequest class]];
        [[[[authorizationRequestStub stub] andReturn:authorizationRequestStub] classMethod] requestWithScopeValues:OCMOCK_ANY
                                                                                                        privacyURL:OCMOCK_ANY
                                                                                                      agreementURL:OCMOCK_ANY
                                                                                                          clientID:OCMOCK_ANY
                                                                                                       environment:OCMOCK_ANY
                                                                                                 callbackURLScheme:OCMOCK_ANY];
        
        [[authorizationRequestStub stub] setAdditionalPayloadAttributes:OCMOCK_ANY];
        [[[authorizationRequestStub stub] andReturn:authorizationRequestStub] alloc];
        
        [[[authorizationRequestStub stub] andDo:^(NSInvocation *invocation) {
            [invocation retainArguments];
            PayPalOneTouchRequestCompletionBlock completionBlock;
            [invocation getArgument:&completionBlock atIndex:2];
            completionBlock(YES, PayPalOneTouchRequestTargetBrowser, nil);
        }] performWithCompletionBlock:OCMOCK_ANY];
        
        NSError *error;
        BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate error:&error];
        
        expect(handled).to.beFalsy();
        expect(error).notTo.beNil();
    });
    
    //with valid initial state and invalid openURL: url
    pending(@"with valid initial state and URL PayPal can't handle");
    pending(@"with valid initial state and URL PayPal can handle - cancel, error, and success results");
    
    it(@"with valid initial state and URL PayPal can handle - success result", ^{
        // Valid initial state requires:
        // - callback URL scheme must start with com.braintreepayments.braintree-demo
        // - callback URL scheme com.braintreepayments.braintree-demo.payments must be found in .plist
        
        // Stubs required by PayPal:
        [[[configuration stub] andReturnValue:@YES] payPalEnabled];
        [[[configuration stub] andReturn:@"http://www.example.com/"] payPalPrivacyPolicyURL];
        [[[configuration stub] andReturn:@"http://www.example.com/"] payPalMerchantUserAgreementURL];
        [[[configuration stub] andReturn:@"offline"] payPalEnvironment];
        [[[configuration stub] andReturn:nil] payPalClientId];
        [[[clientToken stub] andReturn:@"fake-client-token"] originalValue];
        
        id authorizationRequestStub = [OCMockObject mockForClass:[PayPalOneTouchAuthorizationRequest class]];
        [[[[authorizationRequestStub stub] andReturn:authorizationRequestStub] classMethod] requestWithScopeValues:OCMOCK_ANY
                                                                                                        privacyURL:OCMOCK_ANY
                                                                                                      agreementURL:OCMOCK_ANY
                                                                                                          clientID:OCMOCK_ANY
                                                                                                       environment:OCMOCK_ANY
                                                                                                 callbackURLScheme:OCMOCK_ANY];
        
        [[authorizationRequestStub stub] setAdditionalPayloadAttributes:OCMOCK_ANY];
        [[[authorizationRequestStub stub] andReturn:authorizationRequestStub] alloc];
        
        [[[authorizationRequestStub stub] andDo:^(NSInvocation *invocation) {
            [invocation retainArguments];
            PayPalOneTouchRequestCompletionBlock completionBlock;
            [invocation getArgument:&completionBlock atIndex:2];
            completionBlock(YES, PayPalOneTouchRequestTargetBrowser, nil);
        }] performWithCompletionBlock:OCMOCK_ANY];
        
        [[client expect] postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.initiate.started"];
        
        NSError *error;
        BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate error:&error];
        
        expect(handled).to.beTruthy();
        expect(error).to.beNil();
    });
});

SpecEnd
