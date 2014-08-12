#import "BTClientStore.h"

#import "BTClient_Internal.h"

SpecBegin(BTClientStore)

describe(@"fetchClient:", ^{

    __block NSString *tokenString;
    __block NSString *altTokenString;
    beforeEach(^{
        tokenString = @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\",\"paymentAppSchemes\": [\"bt-test-venmo\",\"bt-test-paypal\"]}";
        altTokenString = @"{\"authorizationFingerprint\":\"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key\",\"clientApiUrl\":\"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api\",\"paymentAppSchemes\": [\"a-different-thing\"]}";
    });

    it(@"returns nil if no client has been stored", ^{
        BTClientStore *clientStore = [[BTClientStore alloc] initWithIdentifier:[[NSUUID UUID] UUIDString]];
        expect([clientStore fetchClient]).to.beNil();
    });

    it(@"returns a client if one has been stored", ^{
        BTClientStore *clientStore = [[BTClientStore alloc] initWithIdentifier:[[NSUUID UUID] UUIDString]];
        BTClient *client = [[BTClient alloc] initWithClientToken:tokenString];
        [clientStore storeClient:client];
        BTClient *fetchedClient = [clientStore fetchClient];
        expect(fetchedClient).to.equal(client);
    });

    it(@"returns the same persisted client across different instances with the same identifier", ^{
        NSString *storeIdentifier = [[NSUUID UUID] UUIDString];
        BTClientStore *clientStore1 = [[BTClientStore alloc] initWithIdentifier:storeIdentifier];

        [clientStore1 storeClient:[[BTClient alloc] initWithClientToken:tokenString]];
        BTClient *store1Client = [clientStore1 fetchClient];

        BTClientStore *clientStore2 = [[BTClientStore alloc] initWithIdentifier:storeIdentifier];
        BTClient *store2Client = [clientStore2 fetchClient];

        expect(store1Client).notTo.beIdenticalTo(store2Client);
        expect(store1Client.clientToken).to.equal(store2Client.clientToken);
        expect(store1Client).to.equal(store2Client);
    });

    it(@"returns different clients from instances with different identifiers", ^{
        BTClientStore *clientStore1 = [[BTClientStore alloc] initWithIdentifier:[[NSUUID UUID] UUIDString]];
        [clientStore1 storeClient:[[BTClient alloc] initWithClientToken:tokenString]];
        BTClient *store1Client = [clientStore1 fetchClient];

        BTClientStore *clientStore2 = [[BTClientStore alloc] initWithIdentifier:[[NSUUID UUID] UUIDString]];
        [clientStore2 storeClient:[[BTClient alloc] initWithClientToken:altTokenString]];
        BTClient *store2Client = [clientStore2 fetchClient];

        expect(store1Client).notTo.equal(store2Client);
    });

});

SpecEnd