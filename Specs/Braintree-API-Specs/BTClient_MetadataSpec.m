#import "BTClient_Internal.h"
#import "BTClient+Offline.h"
#import "BTClient+Testing.h"
#import "BTClient_Internal.h"

SpecBegin(BTClient_Metadata)

__block NSString *clientToken;

describe(@"usage of meta by BTClient", ^{
    beforeEach(^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        clientToken = [BTClient offlineTestClientTokenWithAdditionalParameters:nil];
#pragma clang diagnostic pop
    });

    describe(@"copyWithMetadata:", ^{
        __block BTClient *client;
        beforeEach(^{
            XCTestExpectation *clientExpectation = [self expectationWithDescription:@"Setup client"];
            [BTClient setupWithClientToken:clientToken completion:^(BTClient *_client, NSError *error) {
                expect(_client).toNot.beNil();
                client = _client;
                [clientExpectation fulfill];
            }];
            [self waitForExpectationsWithTimeout:3 handler:nil];
        });
        it(@"returns a copy of the client with new metadata", ^{
            BTClient *copied = [client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
                metadata.integration = BTClientMetadataIntegrationDropIn;
                metadata.source = BTClientMetadataSourcePayPalSDK;
            }];
            expect(copied).toNot.beIdenticalTo(client);
            expect(copied.metadata.integration).to.equal(BTClientMetadataIntegrationDropIn);
            expect(copied.metadata.source).to.equal(BTClientMetadataSourcePayPalSDK);
            expect(copied.metadata.sessionId).to.equal(client.metadata.sessionId);
        });
        it(@"does not fail if block is nil", ^{
            BTClient *copied = [client copyWithMetadata:nil];
            expect(copied).toNot.beIdenticalTo(client);
            expect(copied.metadata.integration).to.equal(client.metadata.integration);
            expect(copied.metadata.source).to.equal(client.metadata.source);
            expect(copied.metadata.sessionId).to.equal(client.metadata.sessionId);
        });
    });

    // Using async initializer:

    describe(@"BTClient POST _meta param", ^{

        describe(@"default values", ^{
            BOOL (^isDefaultMetadata)(NSDictionary *) = ^BOOL(NSDictionary *params) {
                BTClientMetadata *defaultMetadata = [[BTClientMetadata alloc] init];
                return [params[@"_meta"][@"integration"] isEqualToString:defaultMetadata.integrationString] &&
                [params[@"_meta"][@"source"] isEqualToString:defaultMetadata.sourceString];
            };

            it(@"includes default _meta parameters in PayPal requests", ^{
                __block BTClient *client;
                XCTestExpectation *clientExpectation = [self expectationWithDescription:@"Setup Client"];
                [BTClient setupWithClientToken:clientToken completion:^(BTClient *_client, NSError *error) {
                    client = _client;
                    [clientExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:3 handler:nil];
                OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
                [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *obj) {
                    return isDefaultMetadata(obj) && [obj[@"_meta"][@"sessionId"] isEqualToString:client.metadata.sessionId];
                }] completion:[OCMArg any]];
                client.clientApiHttp = (id)mockHttp;
                [client savePaypalPaymentMethodWithAuthCode:@"authcode" applicationCorrelationID:@"" success:nil failure:nil];
                [mockHttp verify];
            });

            it(@"includes default _meta parameters in card requests", ^{
                __block BTClient *client;
                XCTestExpectation *clientExpectation = [self expectationWithDescription:@"Setup Client"];
                [BTClient setupWithClientToken:clientToken completion:^(BTClient *_client, NSError *error) {
                    client = _client;
                    [clientExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:3 handler:nil];
                OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
                [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:^BOOL(id obj) {
                    return isDefaultMetadata(obj) && [obj[@"_meta"][@"sessionId"] isEqualToString:client.metadata.sessionId];
                }] completion:[OCMArg any]];
                client.clientApiHttp = (id)mockHttp;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [client saveCardWithNumber:@"4111111111111111" expirationMonth:@"01" expirationYear:@"01" cvv:nil postalCode:nil validate:YES success:nil failure:nil];
#pragma clang diagnostic pop
                [mockHttp verify];
            });

            it(@"includes _meta parameters in coinbase tokenization requests", ^{
                __block BTClient *client;
                XCTestExpectation *clientExpectation = [self expectationWithDescription:@"Setup Client"];
                [BTClient setupWithClientToken:clientToken completion:^(BTClient *_client, NSError *error) {
                    client = _client;
                    [clientExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:3 handler:nil];
                OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
                [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:^BOOL(id obj) {
                    return isDefaultMetadata(obj) && [obj[@"_meta"][@"sessionId"] isEqualToString:client.metadata.sessionId];
                }] completion:[OCMArg any]];
                client.clientApiHttp = (id)mockHttp;
                [client saveCoinbaseAccount:@{ @"code": @"some-coinbase-auth-code" } storeInVault:YES success:nil failure:nil];
                [mockHttp verify];
            });
        });

        describe(@"custom values", ^{

            __block BTClientMutableMetadata *customMetadata;
            __block BTClient *customMetadataClient;
            beforeEach(^{

                customMetadata = [[BTClientMutableMetadata alloc] init];
                customMetadata.integration = BTClientMetadataIntegrationDropIn;
                customMetadata.source = BTClientMetadataSourceForm;
                __block BTClient *client;
                XCTestExpectation *clientExpectation = [self expectationWithDescription:@"Setup Client"];
                [BTClient setupWithClientToken:clientToken completion:^(BTClient *_client, NSError *error) {
                    client = _client;
                    [clientExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:3 handler:nil];
                customMetadataClient = [client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
                    metadata.integration = customMetadata.integration;
                    metadata.source = customMetadata.source;
                }];
            });

            BOOL (^isCustomMetadata)(id) = ^BOOL(id obj) {
                NSDictionary *params = (NSDictionary *)obj;
                return [params[@"_meta"][@"integration"] isEqualToString:customMetadata.integrationString] &&
                [params[@"_meta"][@"source"] isEqualToString:customMetadata.sourceString];
            };

            it(@"includes custom _meta parameters in PayPal requests", ^{
                OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
                [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:isCustomMetadata] completion:[OCMArg any]];
                customMetadataClient.clientApiHttp = (id)mockHttp;
                [customMetadataClient savePaypalPaymentMethodWithAuthCode:@"authcode" applicationCorrelationID:@"" success:nil failure:nil];
                [mockHttp verify];
            });

            it(@"includes default _meta parameters in card requests", ^{
                OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
                [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:isCustomMetadata] completion:[OCMArg any]];
                customMetadataClient.clientApiHttp = (id)mockHttp;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [customMetadataClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"01" expirationYear:@"01" cvv:nil postalCode:nil validate:YES success:nil failure:nil];
#pragma clang diagnostic pop
                [mockHttp verify];
            });
        });
    });

    // Test deprecated behavior:

    describe(@"copyWithMetadata:", ^{
        __block BTClient *client;
        beforeEach(^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            client = [[BTClient alloc] initWithClientToken:clientToken];
#pragma clang diagnostic pop
        });

        it(@"returns a copy of the client with new metadata", ^{
            BTClient *copied = [client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
                metadata.integration = BTClientMetadataIntegrationDropIn;
                metadata.source = BTClientMetadataSourcePayPalSDK;
            }];
            expect(copied).toNot.beIdenticalTo(client);
            expect(copied.metadata.integration).to.equal(BTClientMetadataIntegrationDropIn);
            expect(copied.metadata.source).to.equal(BTClientMetadataSourcePayPalSDK);
        });

        it(@"does not fail if block is nil", ^{
            BTClient *copied = [client copyWithMetadata:nil];
            expect(copied).toNot.beIdenticalTo(client);
            expect(copied.metadata.integration).to.equal(client.metadata.integration);
            expect(copied.metadata.source).to.equal(client.metadata.source);
        });
    });

    describe(@"BTClient POST _meta param", ^{

        describe(@"default values", ^{
            BOOL (^isDefaultMetadata)(NSDictionary *) = ^BOOL(NSDictionary *params) {
                BTClientMetadata *defaultMetadata = [[BTClientMetadata alloc] init];
                return [params[@"_meta"][@"integration"] isEqualToString:defaultMetadata.integrationString] &&
                       [params[@"_meta"][@"source"] isEqualToString:defaultMetadata.sourceString] &&
                       [params[@"_meta"][@"sessionId"] isKindOfClass:[NSString class]];
            };

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

            it(@"includes default _meta parameters in PayPal requests", ^{
                BTClient *client = [[BTClient alloc] initWithClientToken:clientToken];
                OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
                [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *obj) {
                    return isDefaultMetadata(obj) && [obj[@"_meta"][@"sessionId"] isEqualToString:client.metadata.sessionId];
                }] completion:[OCMArg any]];
                client.clientApiHttp = (id)mockHttp;
                [client savePaypalPaymentMethodWithAuthCode:@"authcode" applicationCorrelationID:@"" success:nil failure:nil];
                [mockHttp verify];
            });

            it(@"includes default _meta parameters in card requests", ^{
                BTClient *client = [[BTClient alloc] initWithClientToken:clientToken];
                OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
                [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *obj) {
                    return isDefaultMetadata(obj) && [obj[@"_meta"][@"sessionId"] isEqualToString:client.metadata.sessionId];
                }] completion:[OCMArg any]];
                client.clientApiHttp = (id)mockHttp;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [client saveCardWithNumber:@"4111111111111111" expirationMonth:@"01" expirationYear:@"01" cvv:nil postalCode:nil validate:YES success:nil failure:nil];
#pragma clang diagnostic pop
                [mockHttp verify];
            });
        });

#pragma clang diagnostic pop

        describe(@"custom values", ^{

            __block BTClientMutableMetadata *customMetadata;
            __block BTClient *customMetadataClient, *originalClient;
            beforeEach(^{

                customMetadata = [[BTClientMutableMetadata alloc] init];
                customMetadata.integration = BTClientMetadataIntegrationDropIn;
                customMetadata.source = BTClientMetadataSourceForm;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                originalClient = [[BTClient alloc] initWithClientToken:clientToken];
                customMetadataClient = [originalClient copyWithMetadata:^(BTClientMutableMetadata *metadata) {
                    metadata.integration = customMetadata.integration;
                    metadata.source = customMetadata.source;
                }];
#pragma clang diagnostic pop
            });

            BOOL (^isCustomMetadata)(NSDictionary *) = ^BOOL(NSDictionary *params) {
                return [params[@"_meta"][@"integration"] isEqualToString:customMetadata.integrationString] &&
                       [params[@"_meta"][@"source"] isEqualToString:customMetadata.sourceString] &&
                       [params[@"_meta"][@"sessionId"] isEqualToString:originalClient.metadata.sessionId];
            };

            it(@"includes custom _meta parameters in PayPal requests", ^{
                OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
                [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:isCustomMetadata] completion:[OCMArg any]];
                customMetadataClient.clientApiHttp = (id)mockHttp;
                [customMetadataClient savePaypalPaymentMethodWithAuthCode:@"authcode" applicationCorrelationID:@"" success:nil failure:nil];
                [mockHttp verify];
            });
            
            it(@"includes default _meta parameters in card requests", ^{
                OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
                [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:isCustomMetadata] completion:[OCMArg any]];
                customMetadataClient.clientApiHttp = (id)mockHttp;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [customMetadataClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"01" expirationYear:@"01" cvv:nil postalCode:nil validate:YES success:nil failure:nil];
#pragma clang diagnostic pop
                [mockHttp verify];
            });
        });
    });
});

SpecEnd
