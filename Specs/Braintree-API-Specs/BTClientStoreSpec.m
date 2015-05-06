#import "BTClientStore.h"
#import "BTClient+Offline.h"
#import "BTClient_Internal.h"
#import "BTKeychain.h"
#import "BTTestClientTokenFactory.h"

@interface BTClientTestStore : NSObject
+ (void)reset;
+ (BOOL)setData:(NSData *)data forKey:(NSString *)key;
+ (NSData *)dataForKey:(NSString *)key;
@end

static NSMutableDictionary *_store;

@implementation BTClientTestStore
+ (void)reset {
    _store = [NSMutableDictionary dictionary];
}

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key {
    [_store setObject:data forKey:key];
    return YES;
}
+ (NSData *)dataForKey:(NSString *)key {
    return [_store objectForKey:key];
}
@end

SpecBegin(BTClientStore)

__block id btKeychainMock;

beforeEach(^{
    btKeychainMock = [OCMockObject mockForClass:[BTKeychain class]];
    [BTClientTestStore reset];
    [[[btKeychainMock stub] andCall:@selector(setData:forKey:) onObject:[BTClientTestStore class]] setData:OCMOCK_ANY forKey:OCMOCK_ANY];
    [[[btKeychainMock stub] andCall:@selector(dataForKey:) onObject:[BTClientTestStore class]] dataForKey:OCMOCK_ANY];
});

afterEach(^{
    [btKeychainMock stopMocking];
});

describe(@"fetchClient:", ^{

    __block NSString *tokenString;
    __block NSString *altTokenString;
    __block BTClient *client1;
    __block BTClient *client2;
    beforeEach(^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        tokenString = [BTClient offlineTestClientTokenWithAdditionalParameters:@{ @"authorization_fingerprint": @"authorizationFingerprint1" }];
        altTokenString = [BTClient offlineTestClientTokenWithAdditionalParameters:@{ @"authorization_fingerprint": @"authorizationFingerprint2" }];
#pragma clang diagnostic pop
        XCTestExpectation *client1Expectation = [self expectationWithDescription:@"Setup client1"];
        [BTClient setupWithClientToken:tokenString completion:^(BTClient *_client, NSError *error) {
            client1 = _client;
            [client1Expectation fulfill];
        }];
        XCTestExpectation *client2Expectation = [self expectationWithDescription:@"Setup client2"];
        [BTClient setupWithClientToken:altTokenString completion:^(BTClient *_client, NSError *error) {
            client2 = _client;
            [client2Expectation fulfill];
        }];
        [self waitForExpectationsWithTimeout:3 handler:nil];
    });

    it(@"returns nil if no client has been stored", ^{
        BTClientStore *clientStore = [[BTClientStore alloc] initWithIdentifier:[[NSUUID UUID] UUIDString]];
        expect([clientStore fetchClient]).to.beNil();
    });

    it(@"returns a client if one has been stored", ^{
        BTClientStore *clientStore = [[BTClientStore alloc] initWithIdentifier:[[NSUUID UUID] UUIDString]];
        [clientStore storeClient:client1];
        BTClient *fetchedClient = [clientStore fetchClient];
        expect(fetchedClient).to.equal(client1);
    });

    it(@"returns the same persisted client across different instances with the same identifier", ^{
        NSString *storeIdentifier = [[NSUUID UUID] UUIDString];
        BTClientStore *clientStore1 = [[BTClientStore alloc] initWithIdentifier:storeIdentifier];

        [clientStore1 storeClient:client1];
        BTClient *store1Client = [clientStore1 fetchClient];

        BTClientStore *clientStore2 = [[BTClientStore alloc] initWithIdentifier:storeIdentifier];
        BTClient *store2Client = [clientStore2 fetchClient];

        expect(store1Client).notTo.beIdenticalTo(store2Client);
        expect(store1Client.clientToken).to.equal(store2Client.clientToken);
        expect(store1Client).to.equal(store2Client);
    });

    it(@"returns different clients from instances with different identifiers", ^{
        BTClientStore *clientStore1 = [[BTClientStore alloc] initWithIdentifier:[[NSUUID UUID] UUIDString]];
        [clientStore1 storeClient:client1];
        BTClient *store1Client = [clientStore1 fetchClient];

        BTClientStore *clientStore2 = [[BTClientStore alloc] initWithIdentifier:[[NSUUID UUID] UUIDString]];
        [clientStore2 storeClient:client2];
        BTClient *store2Client = [clientStore2 fetchClient];

        expect(store1Client).notTo.equal(store2Client);
    });
});

describe(@"fetchClient: using deprecated initializer", ^{

    __block NSString *tokenString;
    __block NSString *altTokenString;
    beforeEach(^{
        tokenString = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ @"authorization_fingerprint": @"authorizationFingerprint1" }];
        altTokenString = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ @"authorization_fingerprint": @"authorizationFingerprint2" }];
    });

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

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

#pragma clang diagnostic pop

});

SpecEnd
