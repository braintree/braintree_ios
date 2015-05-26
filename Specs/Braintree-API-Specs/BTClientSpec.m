@import PassKit;

#import "BTClient_Internal.h"
#import "BTClient+Testing.h"
#import "BTTestClientTokenFactory.h"
#import "BTAnalyticsMetadata.h"
#import "BTClientToken.h"
#import "BTLogger_Internal.h"
#import "BTClientSpecHelper.h"


SharedExamplesBegin(BTClient)

sharedExamplesFor(@"a BTClient", ^(NSDictionary *data) {

    __block BOOL asyncClient = [data[@"asyncClient"] boolValue];

    describe(@"BTClient", ^{
        __block OCMockObject *mockLogger;

        beforeEach(^{
            mockLogger = [OCMockObject partialMockForObject:[BTLogger sharedLogger]];
        });

        afterEach(^{
            [mockLogger stopMocking];
        });

        describe(@"initialization", ^{
            it(@"constructs a client when given a valid client token", ^{
                BTClient *client = [BTClientSpecHelper clientForTestCase:self withOverrides:nil async:asyncClient];
                expect(client).to.beKindOf([BTClient class]);
            });

            it(@"returns nil and logs an error when given an invalid client token", ^{
                [[mockLogger expect] error:containsString(@"clientToken was invalid")];
                __block BTClient *client;
                if(asyncClient){
                    XCTestExpectation *expectation = [self expectationWithDescription:@"Create client token"];
                    [BTClient setupWithClientToken:@"invalid token"
                                        completion:^(BTClient *_client, NSError *error) {
                                            client = _client;
                                            expect(error.localizedDescription).to.contain(@"invalid");
                                            [expectation fulfill];
                                        }];
                    [self waitForExpectationsWithTimeout:10 handler:nil];

                } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    client = [[BTClient alloc] initWithClientToken:@"invalid token"];
#pragma clang diagnostic pop
                }
                expect(client).to.beNil();
                [mockLogger verify];

            });

            it(@"should return nil when initialized with NSData instead of a string", ^{
                NSString *invalidString = @"invalidString";
                NSData *invalidStringData = [invalidString dataUsingEncoding:NSUTF8StringEncoding];
                [[mockLogger expect] error:@"BTClient could not initialize because the provided clientToken was invalid"];
                __block BTClient *client;
                if(asyncClient){
                    XCTestExpectation *expectation = [self expectationWithDescription:@"Create client token"];
                    [BTClient setupWithClientToken:(NSString *)invalidStringData
                                        completion:^(BTClient *_client, NSError *error) {
                                            expect(error.localizedDescription).to.contain(@"invalid");
                                            [expectation fulfill];
                                        }];

                    [self waitForExpectationsWithTimeout:10 handler:nil];
                } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    client = [[BTClient alloc] initWithClientToken:(NSString *)invalidStringData];
#pragma clang diagnostic pop
                }
                expect(client).to.beNil();
                [mockLogger verify];
            });
        });
    });

    describe(@"Apple Pay configuration", ^{
        it(@"parses Apple Pay configuration from the client token", ^{
            BTClient *client = [BTClientSpecHelper clientForTestCase:self withOverrides:nil async:asyncClient];

            if ([PKPaymentRequest class]) {
                expect(client.configuration.applePayStatus).to.equal(BTClientApplePayStatusMock);
                expect(client.configuration.applePayCountryCode).to.equal(@"US");
                expect(client.configuration.applePayCurrencyCode).to.equal(@"USD");
                expect(client.configuration.applePayMerchantIdentifier).to.equal(@"apple-pay-merchant-id");
                expect(client.configuration.applePaySupportedNetworks).to.contain(PKPaymentNetworkAmex);
                expect(client.configuration.applePaySupportedNetworks).to.contain(PKPaymentNetworkMasterCard);
                expect(client.configuration.applePaySupportedNetworks).to.contain(PKPaymentNetworkVisa);
            }
        });
    });

    describe(@"post analytics event", ^{
        it(@"sends events to the specified URL", ^{
            NSString *analyticsUrl = @"http://analytics.example.com/path/to/analytics";
            BTClient *client = [BTClientSpecHelper clientForTestCase:self withOverrides:@{ BTConfigurationKeyAnalytics:@{
                                                                                                   BTConfigurationKeyURL:analyticsUrl } } async:asyncClient];
            OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
            [[mockHttp expect] POST:@"/" parameters:[OCMArg any] completion:[OCMArg any]];
            client.analyticsHttp = (id)mockHttp;

            [client postAnalyticsEvent:@"An Event" success:nil failure:nil];
            [mockHttp verify];
        });

        it(@"does not send the event if the analytics url is nil", ^{
            BTClient *client = [BTClientSpecHelper clientForTestCase:self withOverrides:@{ BTConfigurationKeyAnalytics: @{
                                                                                                   BTConfigurationKeyURL: NSNull.null } } async:asyncClient];
            OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
            [[mockHttp reject] POST:[OCMArg any] parameters:[OCMArg any] completion:[OCMArg any]];
            client.analyticsHttp = (id)mockHttp;

            [client postAnalyticsEvent:@"An Event" success:nil failure:nil];
            [mockHttp verify];
        });

        it(@"includes the metadata", ^{
            NSString *analyticsUrl = @"http://analytics.example.com/path/to/analytics";
            __block NSString *expectedSource, *expectedIntegration, *expectedSessionId;
            BTClient *client = [[BTClientSpecHelper clientForTestCase:self withOverrides:@{ BTConfigurationKeyAnalytics:@{
                                                                                                    BTConfigurationKeyURL:analyticsUrl } } async:asyncClient]
                                copyWithMetadata:^(BTClientMutableMetadata *metadata) {
                                    expectedIntegration = [metadata integrationString];
                                    expectedSource = [metadata sourceString];
                                    expectedSessionId = [metadata sessionId];
                                }];

            OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
            [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:^BOOL(id obj) {
                NSDictionary *expectedMetadata = ({
                    NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithDictionary:[BTAnalyticsMetadata metadata]];
                    metadata[@"source"] = expectedSource;
                    metadata[@"integration"] = expectedIntegration;
                    metadata[@"sessionId"] = expectedSessionId;
                    [metadata copy];
                });
                return [obj[@"_meta"] isEqual:expectedMetadata];
            }] completion:[OCMArg any]];
            client.analyticsHttp = (id)mockHttp;

            [client postAnalyticsEvent:@"An Event" success:nil failure:nil];
            [mockHttp verify];
        });
    });

    describe(@"coding", ^{
        it(@"roundtrips the client", ^{
            BTClient *client = [BTClientSpecHelper clientForTestCase:self withOverrides:@{ BTConfigurationKeyClientApiURL: @"http://example.com/api",
                                                                                           BTClientTokenKeyVersion: @2 } async:asyncClient];
            NSMutableData *data = [NSMutableData data];
            NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
            [client encodeWithCoder:coder];
            [coder finishEncoding];
            NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            BTClient *returnedClient = [[BTClient alloc] initWithCoder:decoder];
            [decoder finishDecoding];

            expect(returnedClient.clientToken.authorizationFingerprint).to.equal(client.clientToken.authorizationFingerprint);
            expect(returnedClient.clientApiHttp).to.equal(client.clientApiHttp);
            expect(returnedClient.analyticsHttp).to.equal(client.analyticsHttp);
        });
    });


    describe(@"isEqual:", ^{
        it(@"returns YES if client tokens are equal", ^{
            NSDictionary *overrides = @{ BTConfigurationKeyClientApiURL: @"http://example.com/api",
                                         BTClientTokenKeyVersion: @2 };
            BTClient *client1 = [BTClientSpecHelper clientForTestCase:self withOverrides:overrides async:asyncClient];
            BTClient *client2 = [BTClientSpecHelper clientForTestCase:self withOverrides:overrides async:asyncClient];
            expect(client1).to.equal(client2);
        });

        it(@"returns YES if client tokens are not defined", ^{
            BTClient *client1 = [[BTClient alloc] init];
            BTClient *client2 = [[BTClient alloc] init];
            expect(client1).to.equal(client2);
        });

        it(@"returns NO if client tokens are not equal", ^{
            NSDictionary *overrides1 = @{ BTConfigurationKeyClientApiURL: @"a-scheme://yo",
                                          BTClientTokenKeyVersion: @2};
            NSDictionary *overrides2 = @{ BTConfigurationKeyClientApiURL: @"another-scheme://yo",
                                          BTClientTokenKeyVersion: @2};
            BTClient *client1 = [BTClientSpecHelper clientForTestCase:self withOverrides:overrides1 async:asyncClient];
            BTClient *client2 = [BTClientSpecHelper clientForTestCase:self withOverrides:overrides2 async:asyncClient];
            expect(client1).notTo.equal(client2);
        });

        it(@"returns NO if client tokens differ by authorization fingerprint", ^{
            NSDictionary *overrides1 = @{ BTClientTokenKeyAuthorizationFingerprint: @"an_authorization_fingerprint",
                                          BTClientTokenKeyVersion: @2 };
            NSDictionary *overrides2 = @{ BTClientTokenKeyAuthorizationFingerprint: @"another_authorization_fingerprint",
                                          BTClientTokenKeyVersion: @2 };

            BTClient *client1 = [BTClientSpecHelper clientForTestCase:self withOverrides:overrides1 async:asyncClient];
            BTClient *client2 = [BTClientSpecHelper clientForTestCase:self withOverrides:overrides2 async:asyncClient];
            expect(client1).notTo.equal(client2);
        });
    });

    describe(@"copy of client", ^{
        __block BTClient *client;
        beforeEach(^{
            NSString *analyticsUrl = @"http://analytics.example.com/path/to/analytics";
            NSString *clientTokenString = [BTTestClientTokenFactory tokenWithVersion:2
                                                                           overrides:@{BTConfigurationKeyAnalytics: @{BTConfigurationKeyURL: analyticsUrl}}];
            if (asyncClient) {
                XCTestExpectation *clientExpectation = [self expectationWithDescription:@"Setup client"];
                [BTClient setupWithClientToken:clientTokenString completion:^(BTClient *_client, NSError *error) {
                    expect(_client).notTo.beNil();
                    expect(error).to.beNil();
                    client = _client;
                    [clientExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:3 handler:nil];
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                client = [[BTClient alloc] initWithClientToken:clientTokenString];
#pragma clang diagnostic pop
            }
        });

        it(@"returns a different instance", ^{
            expect([client copy]).toNot.beIdenticalTo(client);
        });

        it(@"returns an equal instance", ^{
            expect([client copy]).to.equal(client);
        });

        it(@"returns an instance with different properties", ^{
            BTClient *copiedClient = [client copy];
            expect(copiedClient.clientToken).notTo.beNil();
            expect(copiedClient.clientToken).notTo.beIdenticalTo(client.clientToken);
            expect(copiedClient.configHttp).notTo.beNil();
            expect(copiedClient.configHttp).notTo.beIdenticalTo(client.configHttp);
            expect(copiedClient.clientApiHttp).notTo.beNil();
            expect(copiedClient.clientApiHttp).notTo.beIdenticalTo(client.clientApiHttp);
            expect(copiedClient.analyticsHttp).notTo.beNil();
            expect(copiedClient.analyticsHttp).notTo.beIdenticalTo(client.analyticsHttp);
        });

        it(@"returns an instance with a copy of configHttp and hasConfiguration", ^{
            BTClient *copiedClient = [client copy];
            expect(copiedClient.configHttp).to.equal(client.configHttp);
            expect(copiedClient.hasConfiguration).to.equal(client.hasConfiguration);
        });
    });

    describe(@"merchantId", ^{
        it(@"can be nil (for old client tokens)", ^{
            BTClient *client = [BTClientSpecHelper clientForTestCase:self withOverrides:@{ BTConfigurationKeyMerchantId: NSNull.null } async:asyncClient];
            expect(client.merchantId).to.beNil();
        });

        it(@"returns the merchant id from the client token", ^{
            BTClient *client = [BTClientSpecHelper clientForTestCase:self withOverrides:@{ BTConfigurationKeyMerchantId: @"merchant-id" } async:asyncClient];
            expect(client.merchantId).to.equal(@"merchant-id");
        });
    });
});

SharedExamplesEnd

SpecBegin(DeprecatedBTClient)

describe(@"shared initialization behavior", ^{
    NSDictionary* data = @{@"asyncClient": @NO};
    itShouldBehaveLike(@"a BTClient", data);
});

SpecEnd

SpecBegin(AsyncBTClient)

describe(@"shared initialization behavior", ^{
    NSDictionary* data = @{@"asyncClient": @YES};
    itShouldBehaveLike(@"a BTClient", data);
});

SpecEnd


