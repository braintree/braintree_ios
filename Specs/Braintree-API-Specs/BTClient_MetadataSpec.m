#import "BTClient_Internal.h"
#import "BTClient+Offline.h"
#import "BTClient+Testing.h"
#import "BTClient_Internal.h"

SpecBegin(BTClient_Metadata)

__block NSString *clientToken;
beforeEach(^{
    clientToken = [BTClient offlineTestClientTokenWithAdditionalParameters:nil];
});

describe(@"copyWithMetadata:", ^{

    __block BTClient *client;
    beforeEach(^{
        client = [[BTClient alloc] initWithClientToken:clientToken];
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
        BOOL (^isDefaultMetadata)(id) = ^BOOL(id obj) {
            BTClientMetadata *defaultMetadata = [[BTClientMetadata alloc] init];
            NSDictionary *params = (NSDictionary *)obj;
            return [params[@"_meta"][@"integration"] isEqualToString:defaultMetadata.integrationString] &&
            [params[@"_meta"][@"source"] isEqualToString:defaultMetadata.sourceString];
        };

        it(@"includes default _meta parameters in PayPal requests", ^{
            BTClient *client = [[BTClient alloc] initWithClientToken:clientToken];
            OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
            [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:isDefaultMetadata] completion:[OCMArg any]];
            client.clientApiHttp = (id)mockHttp;
            [client savePaypalPaymentMethodWithAuthCode:@"authcode" applicationCorrelationID:nil success:nil failure:nil];
            [mockHttp verify];
        });

        it(@"includes default _meta parameters in card requests", ^{
            BTClient *client = [[BTClient alloc] initWithClientToken:clientToken];
            OCMockObject *mockHttp = [OCMockObject mockForClass:[BTHTTP class]];
            [[mockHttp expect] POST:[OCMArg any] parameters:[OCMArg checkWithBlock:isDefaultMetadata] completion:[OCMArg any]];
            client.clientApiHttp = (id)mockHttp;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [client saveCardWithNumber:@"4111111111111111" expirationMonth:@"01" expirationYear:@"01" cvv:nil postalCode:nil validate:YES success:nil failure:nil];
#pragma clang diagnostic pop
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

            customMetadataClient = [[[BTClient alloc] initWithClientToken:clientToken] copyWithMetadata:^(BTClientMutableMetadata *metadata) {
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
            [customMetadataClient savePaypalPaymentMethodWithAuthCode:@"authcode" applicationCorrelationID:nil success:nil failure:nil];
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


SpecEnd
