#import "BTClient+Testing.h"

SpecBegin(BTClientToken_Integration)

describe(@"initForTestingWithConfiguration:", ^{
    it(@"returns a preconfigured client with a version 2 client token", ^{
        waitUntil(^(DoneCallback done){
            [BTClient testClientWithConfiguration:@{
                                                    BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
                                                    BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
                                                    BTClientTestConfigurationKeyCustomer: @"myCustomer",
                                                    BTClientTestConfigurationKeySharedCustomerIdentifier: @"testing",
                                                    BTClientTestConfigurationKeySharedCustomerIdentifierType: @"testing",
                                                    BTClientTestConfigurationKeyClientTokenVersion: @2,
                                                    BTClientTestConfigurationKeyAnalytics: @{ BTClientTestConfigurationKeyURL: @"http://analytics.example.com" }
                                                    }
                                                    async:YES
                                                    completion:^(BTClient *client) {
                                                        expect(client).to.beKindOf([BTClient class]);
                                                        expect(client.challenges).to.equal([NSSet setWithArray:@[]]);
                                                        done();
                                                    }];
        });
    });

    it(@"returns a preconfigured client based on a version 1 client token", ^{
        waitUntil(^(DoneCallback done){
            [BTClient testClientWithConfiguration:@{
                                                    BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
                                                    BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
                                                    BTClientTestConfigurationKeyCustomer: @"myCustomer",
                                                    BTClientTestConfigurationKeySharedCustomerIdentifier: @"testing",
                                                    BTClientTestConfigurationKeySharedCustomerIdentifierType: @"testing",
                                                    BTClientTestConfigurationKeyClientTokenVersion: @1,
                                                    }
                                                    async:YES
                                                    completion:^(BTClient *client) {
                                                        expect(client).to.beKindOf([BTClient class]);
                                                        expect(client.challenges).to.equal([NSSet setWithArray:@[]]);
                                                        done();
                                                    }];
        });
    });
});

SpecEnd
