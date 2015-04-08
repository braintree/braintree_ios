@import PassKit;

#import "BTClient_Internal.h"
#import "BTClient+Offline.h"
#import "BTClient+Testing.h"
#import "BTTestClientTokenFactory.h"
#import "BTAnalyticsMetadata.h"

#import "BTLogger_Internal.h"

SpecBegin(BTClient)

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
            BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:nil]];

            expect(client).to.beKindOf([BTClient class]);
        });

        it(@"returns nil and logs an error when given an invalid client token (also throw an exception in DEBUG)", ^{
            [[mockLogger expect] error:containsString(@"clientToken was invalid")];

            __block BTClient *client;

            switch (BTTestMode) {
                case BTTestModeDebug:
                    expect(^{
                        client = [[BTClient alloc] initWithClientToken:@"invalid token"];
                    }).to.raise(NSInvalidArgumentException);
                    break;
                case BTTestModeRelease:
                    client = [[BTClient alloc] initWithClientToken:@"invalid token"];
                    break;
            }

            expect(client).to.beNil();
            [mockLogger verify];
        });

        describe(@"initialize With Invalid Data", ^{
            it(@"should return nil when initialized with NSData instead of a string", ^{
                NSString *invalidString = @"invalidString";
                NSData *invalidStringData = [invalidString dataUsingEncoding:NSUTF8StringEncoding];
                BTClient *client = [[BTClient alloc] initWithClientToken:(NSString *)invalidStringData];
                [[mockLogger expect] log:containsString(@"BTClient could not initialize because the provided clientToken was invalid")];
                expect(client).to.beNil;
            });
        });
    });

    describe(@"Apple Pay configuration", ^{
        it(@"parses Apple Pay configuration from the client token", ^{
            BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:nil]];

            if ([PKPaymentRequest class]) {
                expect(client.clientToken.applePayStatus).to.equal(BTClientApplePayStatusMock);
                expect(client.clientToken.applePayCountryCode).to.equal(@"US");
                expect(client.clientToken.applePayCurrencyCode).to.equal(@"USD");
                expect(client.clientToken.applePayMerchantIdentifier).to.equal(@"apple-pay-merchant-id");
                expect(client.clientToken.applePaySupportedNetworks).to.contain(PKPaymentNetworkAmex);
                expect(client.clientToken.applePaySupportedNetworks).to.contain(PKPaymentNetworkMasterCard);
                expect(client.clientToken.applePaySupportedNetworks).to.contain(PKPaymentNetworkVisa);
            }
        });
    });
});

describe(@"post analytics event", ^{
    it(@"sends events to the specified URL", ^{
        NSString *analyticsUrl = @"http://analytics.example.com/path/to/analytics";
        BTClient *client = [[BTClient alloc]
                            initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyAnalytics:@{
                                                                                                                  BTClientTokenKeyURL:analyticsUrl } }]];
        OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
        [[mockHttp expect] POST:@"/" parameters:[OCMArg any] completion:[OCMArg any]];
        client.analyticsHttp = (id)mockHttp;

        [client postAnalyticsEvent:@"An Event" success:nil failure:nil];
        [mockHttp verify];
    });

    it(@"does not send the event if the analytics url is nil", ^{
        BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyAnalytics: @{ BTClientTokenKeyURL: NSNull.null } }]];
        OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
        [[mockHttp reject] POST:[OCMArg any] parameters:[OCMArg any] completion:[OCMArg any]];
        client.analyticsHttp = (id)mockHttp;

        [client postAnalyticsEvent:@"An Event" success:nil failure:nil];
        [mockHttp verify];
    });

    it(@"includes the metadata", ^{
        NSString *analyticsUrl = @"http://analytics.example.com/path/to/analytics";
        __block NSString *expectedSource, *expectedIntegration;
        BTClient *client = [[[BTClient alloc]
                             initWithClientToken:[BTClient offlineTestClientTokenWithAdditionalParameters:@{ BTClientTokenKeyAnalytics:@{
                                                                                                                     BTClientTokenKeyURL:analyticsUrl } }]]
                            copyWithMetadata:^(BTClientMutableMetadata *metadata) {
                                expectedIntegration = [metadata integrationString];
                                expectedSource = [metadata sourceString];
                            }];

        OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
        [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:^BOOL(id obj) {
            NSDictionary *expectedMetadata = ({
                NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithDictionary:[BTAnalyticsMetadata metadata]];
                metadata[@"source"] = expectedSource;
                metadata[@"integration"] = expectedIntegration;
                [metadata copy];
            });
            expect(obj[@"_meta"]).to.equal(expectedMetadata);
            return [obj[@"_meta"] isEqual:expectedMetadata];
        }] completion:[OCMArg any]];
        client.analyticsHttp = (id)mockHttp;

        [client postAnalyticsEvent:@"An Event" success:nil failure:nil];
        [mockHttp verify];
    });

});

describe(@"offline clients", ^{
    __block BTClient *offlineClient;

    beforeEach(^{
        offlineClient = [[BTClient alloc] initWithClientToken:[BTClient offlineTestClientTokenWithAdditionalParameters:nil]];
    });

    describe(@"initialization", ^{
        it(@"constructs a client when given the offline test client token", ^{
            expect(offlineClient).to.beKindOf([BTClient class]);
        });
    });

    describe(@"save card", ^{
        it(@"returns the newly saved card", ^{
            waitUntil(^(DoneCallback done){
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111111";
                request.expirationMonth = @"12";
                request.expirationYear = @"2038";
                [offlineClient saveCardWithRequest:request
                                           success:^(BTCardPaymentMethod *card) {
                                               expect(card.nonce).to.beANonce();
                                               expect(card.type).to.equal(BTCardTypeVisa);
                                               expect(card.lastTwo).to.equal(@"11");
                                               done();
                                           } failure:nil];
            });
        });

        it(@"saves cards with the correct card types", ^{
            waitUntil(^(DoneCallback done){
                NSDictionary *cardTypesAndNumbers = @{ @"American Express": @"378282246310005",
                                                       @"Discover": @"6011111111111117",
                                                       @"MasterCard": @"5555555555554444",
                                                       @"Visa": @"4012000077777777",
                                                       @"JCB": @"3530111333300000",
                                                       @"Card": @"1234" };

                [cardTypesAndNumbers enumerateKeysAndObjectsUsingBlock:^(NSString *typeString, NSString *number, BOOL *stop) {
                    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                    request.number = number;
                    request.expirationMonth = @"12";
                    request.expirationYear = @"2038";
                    request.shouldValidate = YES;
                    [offlineClient saveCardWithRequest:request
                                               success:^(BTCardPaymentMethod *card) {
                                                   expect(card.typeString).to.equal(typeString);
                                                   done();
                                               }
                                               failure:nil];
                }];
            });
        });

        it(@"assigns new cards a nonce", ^{
            waitUntil(^(DoneCallback done){
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111111";
                request.expirationMonth = @"12";
                request.expirationYear = @"2038";
                request.shouldValidate = YES;

                [offlineClient saveCardWithRequest:request
                                           success:^(BTPaymentMethod *card) {
                                               expect(card.nonce).to.beANonce();

                                               done();
                                           } failure:nil];
            });
        });

        it(@"assigns each card a unique nonce", ^{
            waitUntil(^(DoneCallback done){
                NSMutableSet *uniqueNoncesReturned = [NSMutableSet set];

                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111111";
                request.expirationMonth = @"12";
                request.expirationYear = @"2038";

                [offlineClient saveCardWithRequest:request
                                           success:^(BTPaymentMethod *card) {
                                               [uniqueNoncesReturned addObject:card.nonce];
                                               [offlineClient saveCardWithRequest:request
                                                                          success:^(BTPaymentMethod *card) {
                                                                              [uniqueNoncesReturned addObject:card.nonce];
                                                                              [offlineClient saveCardWithRequest:request
                                                                                                         success:^(BTPaymentMethod *card){
                                                                                                             [uniqueNoncesReturned addObject:card.nonce];

                                                                                                             expect(uniqueNoncesReturned).to.haveCountOf(3);

                                                                                                             done();
                                                                                                         }
                                                                                                         failure:nil];
                                                                          }
                                                                          failure:nil];
                                           }
                                           failure:nil];
            });
        });

        it(@"accepts a nil success block", ^{
            waitUntil(^(DoneCallback done){
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111111";
                request.expirationMonth = @"12";
                request.expirationYear = @"2038";
                request.shouldValidate = YES;

                [offlineClient saveCardWithRequest:request
                                           success:nil
                                           failure:nil];

                wait_for_potential_async_exceptions(done);
            });
        });

        it(@"accepts a nil failure block", ^{
            waitUntil(^(DoneCallback done){
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111112";
                request.expirationMonth = @"12";
                request.expirationYear = @"2038";
                request.shouldValidate = YES;

                [offlineClient saveCardWithRequest:request
                                           success:nil
                                           failure:nil];

                wait_for_potential_async_exceptions(done);
            });
        });

        it(@"exhibits identical behavior when tokenizing a card", ^{

            BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
            request.number = @"4111111111111111";
            request.shouldValidate = NO;

            [offlineClient saveCardWithRequest:request
                                       success:^(BTCardPaymentMethod *card){

                                           expect(card.lastTwo).to.equal(@"11");
                                       }
                                       failure:nil];
        });
    });

    describe(@"save Paypal account", ^{
        it(@"returns the newly saved account", ^{
            waitUntil(^(DoneCallback done){
                [offlineClient savePaypalPaymentMethodWithAuthCode:@"authCode"
                                          applicationCorrelationID:@"correlationId"
                                                           success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                               expect(paypalPaymentMethod.nonce).to.beANonce();
                                                               expect(paypalPaymentMethod.email).to.endWith(@"@example.com");
                                                               done();
                                                           } failure:nil];
            });
        });
    });

    describe(@"save Apple Pay payments", ^{
        it(@"succeeds if payment is nil in mock mode", ^{
            waitUntil(^(DoneCallback done){
                [offlineClient saveApplePayPayment:nil success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
                    if ([PKPayment class]) {
                        expect(applePayPaymentMethod.nonce).to.beANonce();
                        done();
                    }
                } failure:^(NSError *error) {
                    if (![PKPayment class]) {
                        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                        expect(error.code).to.equal(BTErrorUnsupported);
                        done();
                    }
                }];
            });
        });

        it(@"returns the newly saved account with SDK support for Apple Pay, or calls the failure block if there is no SDK support", ^{
            waitUntil(^(DoneCallback done){
                if ([PKPayment class] && [PKPaymentToken class]) {
                    id payment = [OCMockObject partialMockForObject:[[PKPayment alloc] init]];
                    id paymentToken = [OCMockObject partialMockForObject:[[PKPaymentToken alloc] init]];

                    [[[payment stub] andReturn:paymentToken] token];
                    [[[paymentToken stub] andReturn:[NSData data]] paymentData];


                    [offlineClient saveApplePayPayment:payment
                                               success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
                                                   expect(applePayPaymentMethod.nonce).to.beANonce();
                                                   done();
                                               } failure:nil];
                } else {
                    [offlineClient saveApplePayPayment:nil success:nil failure:^(NSError *error) {
                        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                        expect(error.code).to.equal(BTErrorUnsupported);
                        done();
                    }];
                }
            });
        });

        it(@"if supported, on failure, includes the underlying error", ^{
            if (![PKPayment class] || ![PKPaymentToken class]) {
                return;
            }
            waitUntil(^(DoneCallback done){
                NSError *mockUnderlyingError = [NSError errorWithDomain:@"Foo" code:666 userInfo:nil];
                id mockClientApiHttp = [OCMockObject partialMockForObject:offlineClient.clientApiHttp];
                [[mockClientApiHttp stub] POST:OCMOCK_ANY
                                    parameters:OCMOCK_ANY
                                    completion:[OCMArg checkWithBlock:^BOOL(id obj) {
                    void (^callback)(BTHTTPResponse *, NSError *) = (void (^)(BTHTTPResponse *, NSError *))obj;
                    callback(nil, mockUnderlyingError);
                    return YES;
                }]];

                [offlineClient saveApplePayPayment:nil success:nil failure:^(NSError *error) {
                    expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                    expect(error.code).to.equal(BTUnknownError);
                    expect(error.userInfo[NSUnderlyingErrorKey]).to.equal(mockUnderlyingError);
                    done();
                }];
            });
        });
    });

    describe(@"fetch payment methods", ^{
        it(@"initialy retrieves an empty list", ^{
            waitUntil(^(DoneCallback done){
                [offlineClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
                    expect(paymentMethods).to.haveCountOf(0);
                    done();
                } failure:nil];
            });
        });

        describe(@"deprecated signature", ^{
            __block NSArray *paymentMethods;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            it(@"returns the newly saved card", ^{
                waitUntil(^(DoneCallback done) {
                    [offlineClient saveCardWithNumber:@"4111111111111111"
                                      expirationMonth:@"12"
                                       expirationYear:@"2038"
                                                  cvv:nil
                                           postalCode:nil
                                             validate:YES
                                              success:^(BTCardPaymentMethod *card) {
                                                  expect(card.nonce).to.beANonce();
                                                  expect(card.type).to.equal(BTCardTypeVisa);
                                                  expect(card.lastTwo).to.equal(@"11");
                                                  done();
                                              } failure:nil];
                });
            });

            it(@"saves a cards with the correct card types", ^{
                waitUntil(^(DoneCallback done) {
                    NSDictionary *cardTypesAndNumbers = @{ @"American Express": @"378282246310005",
                                                           @"Discover": @"6011111111111117",
                                                           @"MasterCard": @"5555555555554444",
                                                           @"Visa": @"4012000077777777",
                                                           @"JCB": @"3530111333300000",
                                                           @"Card": @"1234" };

                    [cardTypesAndNumbers enumerateKeysAndObjectsUsingBlock:^(NSString *typeString, NSString *number, BOOL *stop) {
                        [offlineClient saveCardWithNumber:number
                                          expirationMonth:@"12"
                                           expirationYear:@"2038"
                                                      cvv:nil
                                               postalCode:nil
                                                 validate:YES
                                                  success:^(BTCardPaymentMethod *card) {
                                                      expect(card.typeString).to.equal(typeString);
                                                      done();
                                                  }
                                                  failure:nil];
                    }];
                });
            });

            beforeEach(^{
                waitUntil(^(DoneCallback done){
                    [offlineClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"2038" cvv:nil
                                           postalCode:nil validate:YES success:^(BTPaymentMethod *card) {
                                               [offlineClient savePaypalPaymentMethodWithAuthCode:@"authCode"
                                                                         applicationCorrelationID:nil
                                                                                          success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                                                              [offlineClient fetchPaymentMethodsWithSuccess:^(NSArray *fetchedPaymentMethods) {
                                                                                                  paymentMethods = fetchedPaymentMethods;
                                                                                                  done();
                                                                                              } failure:nil];
                                                                                          } failure:nil];
                                           } failure:nil];
                });
            });

            it(@"assigns new cards a nonce", ^{
                waitUntil(^(DoneCallback done){
                    [offlineClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"2038" cvv:nil
                                           postalCode:nil validate:YES success:^(BTPaymentMethod *card) {
                                               expect(card.nonce).to.beANonce();

                                               done();
                                           } failure:nil];
                });
            });

            it(@"assigns each card a unique nonce", ^{
                waitUntil(^(DoneCallback done) {
                    NSMutableSet *uniqueNoncesReturned = [NSMutableSet set];

                    [offlineClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"2038"
                                                  cvv:nil
                                           postalCode:nil
                                             validate:YES success:^(BTPaymentMethod *card) {
                                                 [uniqueNoncesReturned addObject:card.nonce];
                                                 [offlineClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"2038" cvv:nil
                                                                        postalCode:nil validate:YES success:^(BTPaymentMethod *card) {
                                                                            [uniqueNoncesReturned addObject:card.nonce];
                                                                            [offlineClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"2038" cvv:nil
                                                                                                   postalCode:nil validate:YES success:^(BTPaymentMethod *card) {
                                                                                                       [uniqueNoncesReturned addObject:card.nonce];

                                                                                                       expect(uniqueNoncesReturned).to.haveCountOf(3);

                                                                                                       done();
                                                                                                   } failure:nil];
                                                                        } failure:nil];
                                             } failure:nil];
                });
            });

            it(@"accepts a nil success block", ^{
                waitUntil(^(DoneCallback done) {
                    [offlineClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"2038" cvv:nil
                                           postalCode:nil validate:YES success:nil failure:nil];

                    wait_for_potential_async_exceptions(done);
                });
            });

            it(@"accepts a nil failure block", ^{
                waitUntil(^(DoneCallback done) {
                    [offlineClient saveCardWithNumber:@"4111111111111112" expirationMonth:@"12" expirationYear:@"2038" cvv:nil
                                           postalCode:nil validate:YES success:nil failure:nil];

                    wait_for_potential_async_exceptions(done);
                });
            });

            it(@"assigns distinct nonces for each payment method", ^{
                expect([paymentMethods[0] nonce]).notTo.equal([paymentMethods[1] nonce]);
            });
#pragma clang diagnostic pop
        });

        describe(@"save Paypal account", ^{
            it(@"returns the newly saved account", ^{
                waitUntil(^(DoneCallback done) {
                    [offlineClient savePaypalPaymentMethodWithAuthCode:@"authCode"
                                              applicationCorrelationID:@"correlationId"
                                                               success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                                   expect(paypalPaymentMethod.nonce).to.beANonce();
                                                                   expect(paypalPaymentMethod.email).to.endWith(@"@example.com");
                                                                   done();
                                                               } failure:nil];
                });
            });
        });


        describe(@"fetch payment methods", ^{
            it(@"initialy retrieves an empty list", ^{
                waitUntil(^(DoneCallback done) {
                    [offlineClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
                        expect(paymentMethods).to.haveCountOf(0);
                        done();
                    } failure:nil];
                });
            });

            describe(@"with two payment methods on file", ^{
                __block NSArray *paymentMethods;

                beforeEach(^{
                    waitUntil(^(DoneCallback done) {
                        BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                        request.number = @"4111111111111111";
                        request.expirationMonth = @"12";
                        request.expirationYear = @"2038";
                        request.shouldValidate = YES;
                        [offlineClient saveCardWithRequest:request
                                                   success:^(BTPaymentMethod *card){
                                                       [offlineClient savePaypalPaymentMethodWithAuthCode:@"authCode"
                                                                                 applicationCorrelationID:nil
                                                                                                  success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                                                                      [offlineClient fetchPaymentMethodsWithSuccess:^(NSArray *fetchedPaymentMethods) {
                                                                                                          paymentMethods = fetchedPaymentMethods;
                                                                                                          done();
                                                                                                      } failure:nil];
                                                                                                  } failure:nil];
                                                   }
                                                   failure:nil];
                    });
                });

                it(@"returns the list of payment methods", ^{
                    expect(paymentMethods).to.haveCountOf(2);
                    expect([paymentMethods[0] nonce]).to.beANonce();
                    expect([paymentMethods[1] nonce]).to.beANonce();
                });

                it(@"includes saved cards", ^{
                    expect(paymentMethods[1]).to.beKindOf([BTCardPaymentMethod class]);
                    expect([paymentMethods[1] lastTwo]).to.equal(@"11");
                });

                it(@"includes saved PayPal accounts", ^{
                    expect(paymentMethods[0]).to.beKindOf([BTPayPalPaymentMethod class]);
                    expect([paymentMethods[0] email]).to.endWith(@"@example.com");
                });

                it(@"assigns distinct nonces for each payment method", ^{
                    expect([paymentMethods[0] nonce]).notTo.equal([paymentMethods[1] nonce]);
                });
            });

            it(@"accepts a nil success block", ^{
                waitUntil(^(DoneCallback done) {
                    [offlineClient fetchPaymentMethodsWithSuccess:nil failure:nil];

                    wait_for_potential_async_exceptions(done);
                });
            });
        });
    });
});

describe(@"coding", ^{
    it(@"roundtrips the client", ^{
        BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyClientApiURL: @"http://example.com/api" }]];
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
        NSString *sampleClientTokenString = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyClientApiURL: @"http://example.com/api" }];
        BTClient *client1 = [[BTClient alloc] initWithClientToken:sampleClientTokenString];
        BTClient *client2 = [[BTClient alloc] initWithClientToken:sampleClientTokenString];
        expect(client1).to.equal(client2);
    });

    it(@"returns YES if client tokens are not defined", ^{
        BTClient *client1 = [[BTClient alloc] init];
        BTClient *client2 = [[BTClient alloc] init];
        expect(client1).to.equal(client2);
    });

    it(@"returns NO if client tokens are not equal", ^{
        NSString *sampleClientTokenString1 = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyClientApiURL: @"a-scheme://yo" }];
        NSString *sampleClientTokenString2 = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyClientApiURL: @"another-scheme://yo" }];
        BTClient *client1 = [[BTClient alloc] initWithClientToken:sampleClientTokenString1];
        BTClient *client2 = [[BTClient alloc] initWithClientToken:sampleClientTokenString2];
        expect(client1).notTo.equal(client2);
    });

    it(@"returns NO if client tokens differ by authorization fingerprint", ^{
        NSString *sampleClientTokenString1 = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyAuthorizationFingerprint: @"an_authorization_fingerprint" }];
        NSString *sampleClientTokenString2 = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyAuthorizationFingerprint: @"another_authorization_fingerprint" }];
        BTClient *client1 = [[BTClient alloc] initWithClientToken:sampleClientTokenString1];
        BTClient *client2 = [[BTClient alloc] initWithClientToken:sampleClientTokenString2];
        expect(client1).notTo.equal(client2);
    });
});

describe(@"copy", ^{
    __block BTClient *client;
    beforeEach(^{
        NSString *analyticsUrl = @"http://analytics.example.com/path/to/analytics";
        NSDictionary *additionalParameters = @{BTClientTokenKeyAnalytics: @{BTClientTokenKeyURL: analyticsUrl}};
        client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:additionalParameters]];
    });

    it(@"returns a different instance", ^{
        expect([client copy]).toNot.beIdenticalTo(client);
    });

    pending(@"BTClient implementing isEqual:", ^{
        it(@"returns an equal instance", ^{
            expect([client copy]).to.equal(client);
        });
    });

    it(@"returns an instance with different properties", ^{
        BTClient *copiedClient = [client copy];
        expect(copiedClient.clientToken).notTo.beNil();
        expect(copiedClient.clientToken).notTo.beIdenticalTo(client.clientToken);
        expect(copiedClient.clientApiHttp).notTo.beNil();
        expect(copiedClient.clientApiHttp).notTo.beIdenticalTo(client.clientApiHttp);
        expect(copiedClient.analyticsHttp).notTo.beNil();
        expect(copiedClient.analyticsHttp).notTo.beIdenticalTo(client.analyticsHttp);
    });
});


describe(@"merchantId", ^{
    it(@"can be nil (for old client tokens)", ^{
        BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyMerchantId: NSNull.null }]];
        expect(client.merchantId).to.beNil();
    });

    it(@"returns the merchant id from the client token", ^{
        BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyMerchantId: @"merchant-id" }]];
        expect(client.merchantId).to.equal(@"merchant-id");
    });
});

SpecEnd
