#import <coinbase-official/CoinbaseOAuth.h>

#import <UIKit/UIKit.h>
#import "BTCoinbase.h"
#import "BTClient_Internal.h"

SpecBegin(BTCoinbase)

__block id coinbaseAppAuthenticationURLMatcher;
__block id coinbaseWebsiteAuthenticationURLMatcher;

before(^{
    coinbaseAppAuthenticationURLMatcher = [OCMArg checkWithBlock:^BOOL(id obj){
        NSURL *coinbaseAppSwitchURL = obj;
        BOOL schemeMatches = [[coinbaseAppSwitchURL scheme] isEqualToString:@"com.coinbase.oauth-authorize"];
        BOOL pathMatches = [[coinbaseAppSwitchURL path] isEqualToString:@"/oauth/authorize"];
        BOOL queryContainsScopes = [[coinbaseAppSwitchURL query] rangeOfString:@"test-coinbase-scopes"].location != NSNotFound;
        BOOL queryContainsClientId = [[coinbaseAppSwitchURL query] rangeOfString:@"test-coinbase-client-id"].location != NSNotFound;
        BOOL queryContainsMerchantAccount = [[coinbaseAppSwitchURL query] rangeOfString:@"coinbase-merchant-account%40test.example.com"].location != NSNotFound;

        return schemeMatches && pathMatches && queryContainsScopes && queryContainsClientId && queryContainsMerchantAccount;
    }];

    coinbaseWebsiteAuthenticationURLMatcher = [OCMArg checkWithBlock:^BOOL(id obj){
        NSURL *coinbaseAppSwitchURL = obj;
        BOOL schemeMatches = [[coinbaseAppSwitchURL scheme] isEqualToString:@"https"];
        BOOL hostMatches = [[coinbaseAppSwitchURL host] isEqualToString:@"www.coinbase.com"];
        BOOL pathMatches = [[coinbaseAppSwitchURL path] isEqualToString:@"/oauth/authorize"];
        BOOL queryContainsScopes = [[coinbaseAppSwitchURL query] rangeOfString:@"test-coinbase-scopes"].location != NSNotFound;
        BOOL queryContainsClientId = [[coinbaseAppSwitchURL query] rangeOfString:@"test-coinbase-client-id"].location != NSNotFound;
        BOOL queryContainsMerchantAccount = [[coinbaseAppSwitchURL query] rangeOfString:@"coinbase-merchant-account%40test.example.com"].location != NSNotFound;

        return schemeMatches && hostMatches && pathMatches && queryContainsScopes && queryContainsClientId && queryContainsMerchantAccount;
    }];
});

it(@"integrates coinbase sdk", ^{
    expect([CoinbaseOAuth class]).to.beKindOf([NSObject class]);
    expect(CoinbaseErrorDomain).to.beKindOf([NSString class]);
});

describe(@"sharedInstance", ^{
    it(@"returns an instance", ^{
        expect([BTCoinbase sharedCoinbase]).to.beKindOf([BTCoinbase class]);
    });

    it(@"implements a singleton", ^{
        expect([BTCoinbase sharedCoinbase]).to.beIdenticalTo([BTCoinbase sharedCoinbase]);
    });

    it(@"does not impact the designated initializer", ^{
        expect([[BTCoinbase alloc] init]).notTo.beIdenticalTo([BTCoinbase sharedCoinbase]);
    });
});

describe(@"BTAppSwitching", ^{
    describe(@"appSwitchAvailableForClient:", ^{
        it(@"returns YES if coinbase is enabled in the client configuration", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];

            id client = [OCMockObject mockForClass:[BTClient class]];
            [[[client stub] andReturn:configuration] configuration];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];

            expect([coinbase appSwitchAvailableForClient:client]).to.beTruthy();
        });

        it(@"returns NO if coinbase is disabled in the client configuration", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(NO)] coinbaseEnabled];

            id client = [OCMockObject mockForClass:[BTClient class]];
            [[[client stub] andReturn:configuration] configuration];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];

            expect([coinbase appSwitchAvailableForClient:client]).to.beFalsy();
        });

        it(@"returns NO if coinbase is enabled in the client configuration but disabled locally", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];

            id client = [OCMockObject mockForClass:[BTClient class]];
            [[[client stub] andReturn:configuration] configuration];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            coinbase.disabled = YES;

            expect([coinbase appSwitchAvailableForClient:client]).to.beFalsy();
        });

        it(@"returns NO if coinbase is disabled in the client configuration and disabled locally", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(NO)] coinbaseEnabled];

            id client = [OCMockObject mockForClass:[BTClient class]];
            [[[client stub] andReturn:configuration] configuration];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            coinbase.disabled = YES;

            expect([coinbase appSwitchAvailableForClient:client]).to.beFalsy();
        });
    });

    describe(@"initiateAppSwitchWithClient:", ^{
        it(@"switches to the coinbase app when it is available", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];
            [[[configuration stub] andReturn:@"test-coinbase-scopes"] coinbaseScope];
            [[[configuration stub] andReturn:@"test-coinbase-client-id"] coinbaseClientId];
            [[[configuration stub] andReturn:@"coinbase-merchant-account@test.example.com"] coinbaseMerchantAccount];
            
            // "shared_sandbox" does not support coinbase app switch
            [[[configuration stub] andReturn:@"mock"] coinbaseEnvironment];
            
            id client = [OCMockObject mockForClass:[BTClient class]];
            [[[client stub] andReturn:configuration] configuration];
            [[client expect] postAnalyticsEvent:@"ios.coinbase.initiate.started"];
            [[client expect] postAnalyticsEvent:@"ios.coinbase.appswitch.started"];

            id<BTAppSwitchingDelegate> delegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];

            id sharedApplicationStub = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
            [[[sharedApplicationStub expect] andReturnValue:@(YES)] canOpenURL:coinbaseAppAuthenticationURLMatcher];
            [[[sharedApplicationStub expect] andReturnValue:@(YES)] openURL:coinbaseAppAuthenticationURLMatcher];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];

            BOOL appSwitchInitiated = [coinbase initiateAppSwitchWithClient:client
                                                                   delegate:delegate
                                                                      error:NULL];
            expect(appSwitchInitiated).to.beTruthy();
            [sharedApplicationStub verify];
            [client verify];
            
            [sharedApplicationStub stopMocking];
        });

        it(@"falls back to switching to Safari when the coinbase app is not available", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];
            [[[configuration stub] andReturn:@"test-coinbase-scopes"] coinbaseScope];
            [[[configuration stub] andReturn:@"test-coinbase-client-id"] coinbaseClientId];
            [[[configuration stub] andReturn:@"coinbase-merchant-account@test.example.com"] coinbaseMerchantAccount];
            [[[configuration stub] andReturn:@"mock"] coinbaseEnvironment];

            id client = [OCMockObject mockForClass:[BTClient class]];
            [[[client stub] andReturn:configuration] configuration];

            [[client expect] postAnalyticsEvent:@"ios.coinbase.initiate.started"];
            [[client expect] postAnalyticsEvent:@"ios.coinbase.webswitch.started"];

            id<BTAppSwitchingDelegate> delegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];

            id sharedApplicationStub = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
            [[[sharedApplicationStub stub] andReturnValue:@(NO)] canOpenURL:coinbaseAppAuthenticationURLMatcher];
            [[[sharedApplicationStub expect] andReturnValue:@(YES)] openURL:coinbaseWebsiteAuthenticationURLMatcher];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];

            BOOL appSwitchInitiated = [coinbase initiateAppSwitchWithClient:client
                                                                   delegate:delegate
                                                                      error:NULL];
            expect(appSwitchInitiated).to.beTruthy();
            [sharedApplicationStub verify];
            [client verify];
            
            [sharedApplicationStub stopMocking];
        });

        it(@"fails when the developer has not yet provided a return url scheme", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];
            [[[configuration stub] andReturn:@"test-coinbase-scopes"] coinbaseScope];
            [[[configuration stub] andReturn:@"test-coinbase-client-id"] coinbaseClientId];
            [[[configuration stub] andReturn:@"coinbase-merchant-account@test.example.com"] coinbaseMerchantAccount];
            [[[configuration stub] andReturn:@"mock"] coinbaseEnvironment];

            id client = [OCMockObject mockForClass:[BTClient class]];
            [[[client stub] andReturn:configuration] configuration];

            [[client expect] postAnalyticsEvent:@"ios.coinbase.initiate.started"];
            [[client expect] postAnalyticsEvent:@"ios.coinbase.initiate.invalid-return-url-scheme"];

            id<BTAppSwitchingDelegate> delegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];

            id sharedApplicationStub = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
            [[[sharedApplicationStub stub] andReturnValue:@(YES)] canOpenURL:[OCMArg any]];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];

            NSError *error;
            BOOL appSwitchInitiated = [coinbase initiateAppSwitchWithClient:client
                                                                   delegate:delegate
                                                                      error:&error];
            expect(appSwitchInitiated).to.beFalsy();
            expect(error.domain).to.equal(BTAppSwitchErrorDomain);
            expect(error.code).to.equal(BTAppSwitchErrorIntegrationReturnURLScheme);
            expect(error.localizedDescription).to.contain(@"Coinbase is not available");
            [sharedApplicationStub verify];
            [client verify];
            
            [sharedApplicationStub stopMocking];
        });

        it(@"fails when the app switch fails", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];
            [[[configuration stub] andReturn:@"test-coinbase-scopes"] coinbaseScope];
            [[[configuration stub] andReturn:@"test-coinbase-client-id"] coinbaseClientId];
            [[[configuration stub] andReturn:@"coinbase-merchant-account@test.example.com"] coinbaseMerchantAccount];
            [[[configuration stub] andReturn:@"mock"] coinbaseEnvironment];

            id client = [OCMockObject mockForClass:[BTClient class]];
            [[[client stub] andReturn:configuration] configuration];

            [[client expect] postAnalyticsEvent:@"ios.coinbase.initiate.started"];
            [[client expect] postAnalyticsEvent:@"ios.coinbase.initiate.failed"];

            id<BTAppSwitchingDelegate> delegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];

            id sharedApplicationStub = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
            [[[sharedApplicationStub stub] andReturnValue:@(YES)] canOpenURL:[OCMArg any]];

            // This indicates that app switch failed:
            [[[sharedApplicationStub stub] andReturnValue:@(NO)] openURL:[OCMArg any]];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];

            NSError *error;
            BOOL appSwitchInitiated = [coinbase initiateAppSwitchWithClient:client
                                                                   delegate:delegate
                                                                      error:&error];
            expect(appSwitchInitiated).to.beFalsy();
            expect(error.domain).to.equal(BTAppSwitchErrorDomain);
            expect(error.code).to.equal(BTAppSwitchErrorFailed);
            expect(error.localizedDescription).to.contain(@"Coinbase is not available");
            [sharedApplicationStub verify];
            [client verify];
            
            [sharedApplicationStub stopMocking];
        });

        it(@"fails when coinbase is not yet enabled", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(NO)] coinbaseEnabled];
            [[[configuration stub] andReturn:@"mock"] coinbaseEnvironment];

            id client = [OCMockObject mockForClass:[BTClient class]];
            [[[client stub] andReturn:configuration] configuration];

            [[client expect] postAnalyticsEvent:@"ios.coinbase.initiate.started"];
            [[client expect] postAnalyticsEvent:@"ios.coinbase.initiate.unavailable"];

            id<BTAppSwitchingDelegate> delegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];

            id sharedApplicationStub = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
            [[[sharedApplicationStub stub] andReturnValue:@(YES)] canOpenURL:[OCMArg any]];
            [[[sharedApplicationStub stub] andReturnValue:@(NO)] openURL:[OCMArg any]];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];

            NSError *error;
            BOOL appSwitchInitiated = [coinbase initiateAppSwitchWithClient:client
                                                                   delegate:delegate
                                                                      error:&error];
            expect(appSwitchInitiated).to.beFalsy();
            expect(error.domain).to.equal(BTAppSwitchErrorDomain);
            expect(error.code).to.equal(BTAppSwitchErrorDisabled);
            expect(error.localizedDescription).to.contain(@"Coinbase is not available");
            [sharedApplicationStub verify];
            [client verify];
            
            [sharedApplicationStub stopMocking];
        });

        it(@"accepts a NULL error even on failures", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];
            [[[configuration stub] andReturn:@"test-coinbase-scopes"] coinbaseScope];
            [[[configuration stub] andReturn:@"test-coinbase-client-id"] coinbaseClientId];
            [[[configuration stub] andReturn:@"coinbase-merchant-account@test.example.com"] coinbaseMerchantAccount];
            [[[configuration stub] andReturn:@"mock"] coinbaseEnvironment];

            id client = [OCMockObject mockForClass:[BTClient class]];
            [[[client stub] andReturn:configuration] configuration];

            [[client expect] postAnalyticsEvent:@"ios.coinbase.initiate.started"];
            [[client expect] postAnalyticsEvent:@"ios.coinbase.initiate.invalid-return-url-scheme"];

            id<BTAppSwitchingDelegate> delegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];

            id sharedApplicationStub = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
            [[[sharedApplicationStub stub] andReturnValue:@(YES)] canOpenURL:[OCMArg any]];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];

            BOOL appSwitchInitiated = [coinbase initiateAppSwitchWithClient:client
                                                                   delegate:delegate
                                                                      error:NULL];
            expect(appSwitchInitiated).to.beFalsy();
            [sharedApplicationStub verify];
            [client verify];
            
            [sharedApplicationStub stopMocking];
        });

        it(@"does not set an error on success", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];
            [[[configuration stub] andReturn:@"test-coinbase-scopes"] coinbaseScope];
            [[[configuration stub] andReturn:@"test-coinbase-client-id"] coinbaseClientId];
            [[[configuration stub] andReturn:@"coinbase-merchant-account@test.example.com"] coinbaseMerchantAccount];
            [[[configuration stub] andReturn:@"mock"] coinbaseEnvironment];

            id client = [OCMockObject mockForClass:[BTClient class]];
            [[[client stub] andReturn:configuration] configuration];

            [[client expect] postAnalyticsEvent:@"ios.coinbase.initiate.started"];
            [[client expect] postAnalyticsEvent:@"ios.coinbase.appswitch.started"];

            id<BTAppSwitchingDelegate> delegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];

            id sharedApplicationStub = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
            [[[sharedApplicationStub expect] andReturnValue:@(YES)] canOpenURL:coinbaseAppAuthenticationURLMatcher];
            [[[sharedApplicationStub expect] andReturnValue:@(YES)] openURL:coinbaseAppAuthenticationURLMatcher];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];

            NSError *error;
            BOOL appSwitchInitiated = [coinbase initiateAppSwitchWithClient:client
                                                                   delegate:delegate
                                                                      error:&error];
            expect(appSwitchInitiated).to.beTruthy();
            expect(error).to.beNil();
            [sharedApplicationStub verify];
            [client verify];
            
            [sharedApplicationStub stopMocking];
        });
    });

    describe(@"canHandleReturnURL:sourceApplication:", ^{
        it(@"returns YES when the url matches the redirect URI regardless of the source application", ^{
            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];

            NSURL *testURL = [NSURL URLWithString:@"com.example.app.payments://x-callback-url/vzero/auth/coinbase/redirect?code=fake_coinbase_auth_code"];
            BOOL canHandleURL = [coinbase canHandleReturnURL:testURL sourceApplication:@"any source application"];

            expect(canHandleURL).to.beTruthy();
        });

        it(@"returns YES when the return url indicates an error", ^{
            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];

            NSURL *testURL = [NSURL URLWithString:@"com.example.app.payments://x-callback-url/vzero/auth/coinbase/redirect?error_message=some_test_error_message&random=thing"];
            BOOL canHandleURL = [coinbase canHandleReturnURL:testURL sourceApplication:@"any source application"];

            expect(canHandleURL).to.beTruthy();
        });

        it(@"returns NO when the return url scheme has not been set", ^{
            BTCoinbase *coinbase = [[BTCoinbase alloc] init];

            NSURL *testURL = [NSURL URLWithString:@"com.example.app.payments://x-callback-url/vzero/auth/coinbase/redirect?code=fake_coinbase_auth_code"];
            BOOL canHandleURL = [coinbase canHandleReturnURL:testURL sourceApplication:@"any source application"];
            expect(canHandleURL).to.beFalsy();
        });

        it(@"returns NO when the url's scheme does not match the return url scheme", ^{
            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.other-app.payments"];

            NSURL *testURL = [NSURL URLWithString:@"com.example.app.payments://x-callback-url/vzero/auth/coinbase/redirect?code=fake_coinbase_auth_code"];
            BOOL canHandleURL = [coinbase canHandleReturnURL:testURL sourceApplication:@"any source application"];
            expect(canHandleURL).to.beFalsy();
        });

        it(@"returns NO when the path specifies a different payment option", ^{
            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];

            NSURL *testURL = [NSURL URLWithString:@"com.example.app.payments://x-callback-url/vzero/auth/venmo/success?key=value"];
            BOOL canHandleURL = [coinbase canHandleReturnURL:testURL sourceApplication:@"any source application"];
            expect(canHandleURL).to.beFalsy();
        });
    });

    describe(@"handleReturnURL:", ^{
        it(@"no-ops if the return URL cannot be handled according to canHandleReturnURL:sourceApplication:", ^{
            id mockDelegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];
            coinbase.delegate = mockDelegate;

            NSURL *testURL = [NSURL URLWithString:@"com.example.random-app://some/unrelated/url"];
            [coinbase handleReturnURL:testURL];
        });

        describe(@"initiateAppSwitchWithClient:delegate: followed by handleReturnURL: tokenizes the code and sends analytics", ^{

            __block id mockClient;
            __block BTCoinbasePaymentMethod *mockPaymentMethod;
            __block NSURL *testURL;
            __block id mockDelegate;
            __block BTCoinbase *coinbase;
            __block id coinbaseOAuth;

            beforeEach(^{
                id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
                [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];
                [[[configuration stub] andReturn:@"test-coinbase-scopes"] coinbaseScope];
                [[[configuration stub] andReturn:@"test-coinbase-client-id"] coinbaseClientId];
                [[[configuration stub] andReturn:@"coinbase-merchant-account@test.example.com"] coinbaseMerchantAccount];
                [[[configuration stub] andReturn:@"mock"] coinbaseEnvironment];
                
                mockClient = [OCMockObject mockForClass:[BTClient class]];
                [[[mockClient stub] andReturn:configuration] configuration];
                mockPaymentMethod = [OCMockObject mockForClass:[BTCoinbasePaymentMethod class]];

                [[[mockClient stub] andDo:^(NSInvocation *invocation){
                    BTClientCoinbaseSuccessBlock successBlock;
                    [invocation retainArguments];
                    [invocation getArgument:&successBlock atIndex:4];
                    successBlock(mockPaymentMethod);
                }] saveCoinbaseAccount:HC_hasEntry(@"code", @"fake_coinbase_auth_code") storeInVault:NO success:[OCMArg isNotNil] failure:[OCMArg any]];
                
                mockDelegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];

                coinbase = [[BTCoinbase alloc] init];
                [coinbase setReturnURLScheme:@"com.example.app.payments"];
                coinbase.delegate = mockDelegate;

                id partialCoinbaseMock = [OCMockObject partialMockForObject:coinbase];
                [[[partialCoinbaseMock stub] andReturn:mockClient] client];

                // All of these tests should initiate coinbase
                [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.initiate.started"];

                coinbaseOAuth = [OCMockObject mockForClass:[CoinbaseOAuth class]];
            });

            afterEach(^{
                [coinbase initiateAppSwitchWithClient:mockClient delegate:mockDelegate error:nil];
                [coinbase handleReturnURL:testURL];
                [mockDelegate verifyWithDelay:10];
                [mockClient verify];
            });

            describe(@"happy path", ^{

                beforeEach(^{
                    testURL = [NSURL URLWithString:@"com.example.app.payments://x-callback-url/vzero/auth/coinbase/redirect?code=fake_coinbase_auth_code"];
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.tokenize.succeeded"];
                    
                    // with a non-mock BTClient, this is used to set metadata.source
                    [[[mockClient stub] andReturn:mockClient] copyWithMetadata:[OCMArg isNotNil]];
                });

                afterEach(^{
                    [[mockDelegate expect] appSwitcher:coinbase didCreatePaymentMethod:mockPaymentMethod];
                });

                it(@"successfully tokenizes code from provider app switch", ^{
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.appswitch.started"];
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.appswitch.authorized"];
                    [[mockDelegate expect] appSwitcherWillCreatePaymentMethod:coinbase];
                    [[[[coinbaseOAuth expect] classMethod] andReturnValue:@(CoinbaseOAuthMechanismApp)] startOAuthAuthenticationWithClientId:OCMOCK_ANY scope:OCMOCK_ANY redirectUri:OCMOCK_ANY meta:OCMOCK_ANY];
                });

                it(@"successfully tokenizes code from web browser switch", ^{
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.webswitch.started"];
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.webswitch.authorized"];
                    [[mockDelegate expect] appSwitcherWillCreatePaymentMethod:coinbase];
                    [[[[coinbaseOAuth expect] classMethod] andReturnValue:@(CoinbaseOAuthMechanismBrowser)] startOAuthAuthenticationWithClientId:OCMOCK_ANY scope:OCMOCK_ANY redirectUri:OCMOCK_ANY meta:OCMOCK_ANY];
                });
            });

            describe(@"coinbase authorization failure cases", ^{

                it(@"returns the error returned by coinbase provider app switch", ^{
                    testURL = [NSURL URLWithString:@"com.example.app.payments://x-callback-url/vzero/auth/coinbase/redirect?error_description=This%20is%20a%20test%20error"];
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.appswitch.started"];
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.appswitch.failed"];
                    [[[[coinbaseOAuth expect] classMethod] andReturnValue:@(CoinbaseOAuthMechanismApp)] startOAuthAuthenticationWithClientId:OCMOCK_ANY scope:OCMOCK_ANY redirectUri:OCMOCK_ANY meta:OCMOCK_ANY];
                    [[mockDelegate expect] appSwitcher:coinbase
                                      didFailWithError:HC_allOf(HC_hasProperty(@"domain", CoinbaseErrorDomain),
                                                                HC_hasProperty(@"code", HC_equalToInteger(CoinbaseOAuthError)),
                                                                HC_hasProperty(@"localizedDescription", @"This is a test error"),
                                                                nil)];
                });

                it(@"returns the error returned by coinbase web browser switch", ^{
                    testURL = [NSURL URLWithString:@"com.example.app.payments://x-callback-url/vzero/auth/coinbase/redirect?error_description=This%20is%20a%20test%20error"];
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.webswitch.started"];
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.webswitch.failed"];
                    [[[[coinbaseOAuth expect] classMethod] andReturnValue:@(CoinbaseOAuthMechanismBrowser)] startOAuthAuthenticationWithClientId:OCMOCK_ANY scope:OCMOCK_ANY redirectUri:OCMOCK_ANY meta:OCMOCK_ANY];
                    [[mockDelegate expect] appSwitcher:coinbase
                                      didFailWithError:HC_allOf(HC_hasProperty(@"domain", CoinbaseErrorDomain),
                                                                HC_hasProperty(@"code", HC_equalToInteger(CoinbaseOAuthError)),
                                                                HC_hasProperty(@"localizedDescription", @"This is a test error"),
                                                                nil)];
                });

                it(@"informs delegate when buyer Denies authorization in provider app", ^{
                    testURL = [NSURL URLWithString:@"com.example.app.payments://x-callback-url/vzero/auth/coinbase/redirect?error_description=This%20is%20a%20test%20error&error=access_denied"];
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.appswitch.started"];
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.appswitch.denied"];
                    [[[[coinbaseOAuth expect] classMethod] andReturnValue:@(CoinbaseOAuthMechanismApp)] startOAuthAuthenticationWithClientId:OCMOCK_ANY scope:OCMOCK_ANY redirectUri:OCMOCK_ANY meta:OCMOCK_ANY];
                    [[mockDelegate expect] appSwitcherDidCancel:coinbase];
                });

                it(@"informs delegate when buyer Denies authorization in web browser", ^{
                    testURL = [NSURL URLWithString:@"com.example.app.payments://x-callback-url/vzero/auth/coinbase/redirect?error_description=This%20is%20a%20test%20error&error=access_denied"];
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.webswitch.started"];
                    [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.webswitch.denied"];
                    [[[[coinbaseOAuth expect] classMethod] andReturnValue:@(CoinbaseOAuthMechanismBrowser)] startOAuthAuthenticationWithClientId:OCMOCK_ANY scope:OCMOCK_ANY redirectUri:OCMOCK_ANY meta:OCMOCK_ANY];
                    [[mockDelegate expect] appSwitcherDidCancel:coinbase];

                });
            });
        });

        it(@"returns a Braintree app switch error when the coinbase response cannot be parsed", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];
            [[[configuration stub] andReturn:@"test-coinbase-scopes"] coinbaseScope];
            [[[configuration stub] andReturn:@"test-coinbase-client-id"] coinbaseClientId];
            [[[configuration stub] andReturn:@"coinbase-merchant-account@test.example.com"] coinbaseMerchantAccount];
            [[[configuration stub] andReturn:@"mock"] coinbaseEnvironment];
            
            id mockClient = [OCMockObject mockForClass:[BTClient class]];
            [[[mockClient stub] andReturn:configuration] configuration];
            id mockDelegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];

            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];
            coinbase.delegate = mockDelegate;

            [[mockDelegate expect] appSwitcher:coinbase
                              didFailWithError:HC_allOf(
                                                        HC_hasProperty(@"domain", CoinbaseErrorDomain),
                                                        HC_hasProperty(@"code", HC_equalToInteger(CoinbaseOAuthError)),
                                                        HC_hasProperty(@"localizedDescription", @"Malformed URL."),
                                                        nil)];

            NSURL *testURL = [NSURL URLWithString:@"com.example.app.payments://x-callback-url/vzero/auth/coinbase/redirect?something=unexpected"];
            [coinbase handleReturnURL:testURL];

            [mockDelegate verifyWithDelay:10];
        });

        it(@"returns the error returned by BTClient when tokenization fails", ^{
            id configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            [[[configuration stub] andReturnValue:@(YES)] coinbaseEnabled];
            [[[configuration stub] andReturn:@"test-coinbase-scopes"] coinbaseScope];
            [[[configuration stub] andReturn:@"test-coinbase-client-id"] coinbaseClientId];
            [[[configuration stub] andReturn:@"coinbase-merchant-account@test.example.com"] coinbaseMerchantAccount];
            [[[configuration stub] andReturn:@"mock"] coinbaseEnvironment];
            
            id mockClient = [OCMockObject mockForClass:[BTClient class]];
            [[[mockClient stub] andReturn:configuration] configuration];
            NSError *mockError = [OCMockObject mockForClass:[NSError class]];
            [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.unknown.authorized"];
            [[mockClient expect] postAnalyticsEvent:@"ios.coinbase.tokenize.failed"];

            id clientStub = [mockClient stub];
            [clientStub andDo:^(NSInvocation *invocation){
                BTClientFailureBlock failureBlock;
                [invocation retainArguments];
                [invocation getArgument:&failureBlock atIndex:5];
                failureBlock(mockError);
            }];
            [clientStub saveCoinbaseAccount:HC_hasEntry(@"code", @"fake_coinbase_auth_code")
                               storeInVault:NO
                                    success:[OCMArg isNotNil]
                                    failure:[OCMArg any]];
            
            // with a non-mock BTClient, this is used to set metadata.source
            [[[mockClient stub] andReturn:mockClient] copyWithMetadata:[OCMArg isNotNil]];
            
            id mockDelegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];
            
            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];
            coinbase.delegate = mockDelegate;

            [[mockDelegate expect] appSwitcherWillCreatePaymentMethod:coinbase];
            
            id partialCoinbaseMock = [OCMockObject partialMockForObject:coinbase];
            [[[partialCoinbaseMock stub] andReturn:mockClient] client];
            
            [[mockDelegate expect] appSwitcher:coinbase didFailWithError:mockError];
            
            NSURL *testURL = [NSURL URLWithString:@"com.example.app.payments://x-callback-url/vzero/auth/coinbase/redirect?code=fake_coinbase_auth_code"];
            [coinbase handleReturnURL:testURL];
            
            [mockDelegate verifyWithDelay:10];
            [mockClient verify];
        });
    });

    describe(@"providerAppSwitchAvailableForClient:", ^{
        __block id configuration, client, coinbaseOAuth;

        beforeEach(^{
            configuration = [OCMockObject mockForClass:[BTConfiguration class]];
            client = [OCMockObject mockForClass:[BTClient class]];
            coinbaseOAuth = [OCMockObject mockForClass:[CoinbaseOAuth class]];
        });

        it(@"returns YES if the app is installed and coinbase is enabled", ^{
            [[[configuration expect] andReturnValue:@YES] coinbaseEnabled];
            [[[client expect] andReturn:configuration] configuration];
            [[[[coinbaseOAuth expect] andReturnValue:@YES] classMethod] isAppOAuthAuthenticationAvailable];
            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];
            expect([coinbase providerAppSwitchAvailableForClient:client]).to.beTruthy();
        });

        it(@"returns NO if the returnURLScheme is not set", ^{
            [[[configuration expect] andReturnValue:@YES] coinbaseEnabled];
            [[[client expect] andReturn:configuration] configuration];
            [[[[coinbaseOAuth expect] andReturnValue:@YES] classMethod] isAppOAuthAuthenticationAvailable];
            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            expect([coinbase providerAppSwitchAvailableForClient:client]).to.beFalsy();
        });

        it(@"returns NO if the app is installed but coinbase is NOT enabled", ^{
            [[[configuration expect] andReturnValue:@NO] coinbaseEnabled];
            [[[client expect] andReturn:configuration] configuration];
            [[[[coinbaseOAuth expect] andReturnValue:@YES] classMethod] isAppOAuthAuthenticationAvailable];
            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];
            expect([coinbase providerAppSwitchAvailableForClient:client]).to.beFalsy();
        });

        it(@"returns NO if the app is NOT installed and coinbase is enabled", ^{
            [[[configuration expect] andReturnValue:@YES] coinbaseEnabled];
            [[[client expect] andReturn:configuration] configuration];
            [[[[coinbaseOAuth expect] andReturnValue:@NO] classMethod] isAppOAuthAuthenticationAvailable];
            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];
            expect([coinbase providerAppSwitchAvailableForClient:client]).to.beFalsy();
        });

        it(@"returns NO if the app is NOT installed and coinbase is NOT enabled", ^{
            [[[configuration expect] andReturnValue:@NO] coinbaseEnabled];
            [[[client expect] andReturn:configuration] configuration];
            [[[[coinbaseOAuth expect] andReturnValue:@NO] classMethod] isAppOAuthAuthenticationAvailable];
            BTCoinbase *coinbase = [[BTCoinbase alloc] init];
            [coinbase setReturnURLScheme:@"com.example.app.payments"];
            expect([coinbase providerAppSwitchAvailableForClient:client]).to.beFalsy();
        });
    });
});

SpecEnd
