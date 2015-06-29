#import "BTClientMetadata.h"

SpecBegin(BTClientMetadata)

describe(@"string values", ^{

    BTClientMutableMetadata *m = [[BTClientMutableMetadata alloc] init];

    it(@"source returns expected strings", ^{
        m.source = BTClientMetadataSourceForm;
        expect(m.sourceString).to.equal(@"form");

        m.source = BTClientMetadataSourceUnknown;
        expect(m.sourceString).to.equal(@"unknown");

        m.source = BTClientMetadataSourcePayPalSDK;
        expect(m.sourceString).to.equal(@"paypal-sdk");

        m.source = BTClientMetadataSourcePayPalApp;
        expect(m.sourceString).to.equal(@"paypal-app");

        m.source = BTClientMetadataSourceCoinbaseApp;
        expect(m.sourceString).to.equal(@"coinbase-app");

        m.source = BTClientMetadataSourceCoinbaseBrowser;
        expect(m.sourceString).to.equal(@"coinbase-browser");

        m.source = BTClientMetadataSourceVenmoApp;
        expect(m.sourceString).to.equal(@"venmo-app");

    });

    it(@"integration returns expected strings", ^{
        m.integration = BTClientMetadataIntegrationDropIn;
        expect(m.integrationString).to.equal(@"dropin");

        m.integration = BTClientMetadataIntegrationCustom;
        expect(m.integrationString).to.equal(@"custom");

        m.integration = BTClientMetadataIntegrationUnknown;
        expect(m.integrationString).to.equal(@"unknown");
    });

    it(@"sessionId returns a 32 character UUID string", ^{
        expect(m.sessionId.length).to.equal(32);
    });

    it(@"sessionId should be different than a different instance's sessionId", ^{
        BTClientMutableMetadata *m2 = [BTClientMutableMetadata new];
        expect(m.sessionId).notTo.equal(m2.sessionId);
    });

});

sharedExamplesFor(@"a copied metadata instance", ^(NSDictionary *data) {
    __block BTClientMetadata *original, *copied;
    
    beforeEach(^{
        original = data[@"original"];
        copied = data[@"copy"];
    });
    
    it(@"has the same values", ^{
        expect(copied.integration).to.equal(original.integration);
        expect(copied.source).to.equal(original.source);
        expect(copied.sessionId).to.equal(original.sessionId);
    });
});


describe(@"mutableMetadata", ^{

    __block BTClientMutableMetadata *mutableMetadata;

    beforeEach(^{
        mutableMetadata = [[BTClientMutableMetadata alloc] init];
    });

    describe(@"init", ^{
        it(@"has expected default values", ^{
            expect(mutableMetadata.integration).to.equal(BTClientMetadataIntegrationCustom);
            expect(mutableMetadata.source).to.equal(BTClientMetadataSourceUnknown);
        });
    });

    context(@"with non-default values", ^{
        beforeEach(^{
            mutableMetadata.integration = BTClientMetadataIntegrationDropIn;
            mutableMetadata.source = BTClientMetadataSourcePayPalSDK;
        });

        describe(@"copy", ^{
            __block BTClientMetadata *copied;
            beforeEach(^{
                copied = [mutableMetadata copy];
            });
            
            itBehavesLike(@"a copied metadata instance", ^{
                return @{@"original" : mutableMetadata,
                         @"copy" : copied};
            });

            it(@"returns a different, immutable instance", ^{
                expect(mutableMetadata).toNot.beIdenticalTo(copied);
                expect([copied isKindOfClass:[BTClientMetadata class]]).to.beTruthy();
                expect([copied isKindOfClass:[BTClientMutableMetadata class]]).to.beFalsy();
            });
        });

        describe(@"mutableCopy", ^{
            __block BTClientMutableMetadata *copied;
            beforeEach(^{
                copied = [mutableMetadata mutableCopy];
            });
            
            itBehavesLike(@"a copied metadata instance", ^{
                return @{@"original" : mutableMetadata,
                         @"copy" : copied};
            });

            it(@"returns a different, immutable instance", ^{
                expect(mutableMetadata).toNot.beIdenticalTo(copied);
                expect([copied isKindOfClass:[BTClientMetadata class]]).to.beTruthy();
                expect([copied isKindOfClass:[BTClientMutableMetadata class]]).to.beTruthy();
            });
        });
    });
});

describe(@"metadata", ^{

    __block BTClientMetadata *metadata;

    beforeEach(^{
        metadata = [[BTClientMetadata alloc] init];
    });

    describe(@"init", ^{
        it(@"has expected default values", ^{
            expect(metadata.integration).to.equal(BTClientMetadataIntegrationCustom);
            expect(metadata.source).to.equal(BTClientMetadataSourceUnknown);
        });
    });

    context(@"with non-default values", ^{
        beforeEach(^{
            metadata = ({
                BTClientMutableMetadata *mutableMetadata = [[BTClientMutableMetadata alloc] init];
                mutableMetadata.integration = BTClientMetadataIntegrationDropIn;
                mutableMetadata.source = BTClientMetadataSourcePayPalSDK;
                [mutableMetadata copy];
            });
        });

        describe(@"copy", ^{
            __block BTClientMetadata *copied;
            beforeEach(^{
                copied = [metadata copy];
            });
            
            itBehavesLike(@"a copied metadata instance", ^{
                return @{@"original" : metadata,
                         @"copy" : copied};
            });

            it(@"returns a different, immutable instance", ^{
                expect(metadata).toNot.beIdenticalTo(copied);
                expect([copied isKindOfClass:[BTClientMetadata class]]).to.beTruthy();
                expect([copied isKindOfClass:[BTClientMutableMetadata class]]).to.beFalsy();
            });
        });

        describe(@"mutableCopy", ^{
            __block BTClientMutableMetadata *copied;
            beforeEach(^{
                copied = [metadata mutableCopy];
            });
            
            itBehavesLike(@"a copied metadata instance", ^{
                return @{@"original" : metadata,
                         @"copy" : copied};
            });

            it(@"returns a different, immutable instance", ^{
                expect(copied).toNot.beIdenticalTo(metadata);
                expect([copied isKindOfClass:[BTClientMetadata class]]).to.beTruthy();
                expect([copied isKindOfClass:[BTClientMutableMetadata class]]).to.beTruthy();
            });
        });
    });
});

SpecEnd
