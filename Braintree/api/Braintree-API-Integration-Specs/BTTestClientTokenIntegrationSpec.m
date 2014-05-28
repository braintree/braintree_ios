#import "BTClient+Testing.h"

SpecBegin(BTClientToken_Integration)

describe(@"initForTestingWithConfiguration:", ^{
    it(@"returns a preconfigured client", ^AsyncBlock{
        [BTClient testClientWithConfiguration:@{
           BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
           BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
           BTClientTestConfigurationKeyCustomer: @"myCustomer",
           BTClientTestConfigurationKeySharedCustomerIdentifier: @"testing",
           BTClientTestConfigurationKeySharedCustomerIdentifierType: @"testing",
           BTClientTestConfigurationKeyBaseUrl: @"http://example.com/"
           } completion:^(BTClient *client) {
               expect(client).to.beKindOf([BTClient class]);
               expect(client.challenges).to.equal([NSSet setWithArray:@[@"cvv", @"postal_code"]]);
               done();
           }];
    });
});

SpecEnd