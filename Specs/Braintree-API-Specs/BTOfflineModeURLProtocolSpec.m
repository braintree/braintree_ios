#import "BTOfflineModeURLProtocol.h"
#import "BTOfflineClientBackend.h"

SpecBegin(BTOfflineModeURLProtocol)

describe(@"backend", ^{
    it(@"can be saved and retrieved at the class level", ^{
        BTOfflineClientBackend *aBackend = [BTOfflineClientBackend new];
        id original = [BTOfflineModeURLProtocol backend];
        [BTOfflineModeURLProtocol setBackend:nil];
        expect([BTOfflineModeURLProtocol backend]).to.beNil();
        [BTOfflineModeURLProtocol setBackend:aBackend];
        expect([BTOfflineModeURLProtocol backend]).to.equal(aBackend);
        [BTOfflineModeURLProtocol setBackend:nil];
        expect([BTOfflineModeURLProtocol backend]).to.beNil();
        [BTOfflineModeURLProtocol setBackend:original];
    });
});

describe(@"canInitWithRequest:", ^{
    it(@"serves URLs with the magic scheme", ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:BTOfflineModeClientApiBaseURL]];
        expect([BTOfflineModeURLProtocol canInitWithRequest:request]).to.beTruthy();
    });

    it(@"does not serve normal http requests", ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com"]];
        expect([BTOfflineModeURLProtocol canInitWithRequest:request]).to.beFalsy();
    });

    it(@"does not serve normal https requests", ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://example.com"]];
        expect([BTOfflineModeURLProtocol canInitWithRequest:request]).to.beFalsy();
    });

    it(@"only serves URLs with the correct host, even if they have the correct scheme", ^{
        NSURL *url = [[NSURL alloc] initWithScheme:[[BTOfflineModeURLProtocol clientApiBaseURL] scheme] host:@"incorrect" path:@"/"];

        NSURLRequest *request = [NSURLRequest requestWithURL:url];

        expect([BTOfflineModeURLProtocol canInitWithRequest:request]).to.beFalsy();
    });
});

describe(@"cannonicalRequestForRequest:", ^{
    it(@"passes through the original request", ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:[BTOfflineModeURLProtocol clientApiBaseURL]];

        expect([BTOfflineModeURLProtocol canonicalRequestForRequest:request]).to.beIdenticalTo(request);
    });
});

describe(@"startLoading", ^{
    it(@"immediately responds to the client", ^{
        NSURL *url = [NSURL URLWithString:@"v1/payment_methods" relativeToURL:[BTOfflineModeURLProtocol clientApiBaseURL]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];

        OCMockObject<NSURLProtocolClient> *mockURLProtocolClient = [OCMockObject mockForProtocol:@protocol(NSURLProtocolClient)];

        BTOfflineModeURLProtocol *offlineURLProtocol = [[BTOfflineModeURLProtocol alloc] initWithRequest:request cachedResponse:nil client:mockURLProtocolClient];

        [mockURLProtocolClient setExpectationOrderMatters:YES];
        [[mockURLProtocolClient expect] URLProtocol:offlineURLProtocol didReceiveResponse:[OCMArg checkWithBlock:^BOOL(NSHTTPURLResponse *response) {
            return response.statusCode == 200;
        }] cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [[mockURLProtocolClient expect] URLProtocol:offlineURLProtocol didLoadData:[OCMArg isNotNil]];
        [[mockURLProtocolClient expect] URLProtocolDidFinishLoading:offlineURLProtocol];

        [offlineURLProtocol startLoading];

        [mockURLProtocolClient verify];
        [mockURLProtocolClient stopMocking];
    });

    it(@"loads a 501 not implemented for unimplemented routes", ^{
        NSURL *url = [NSURL URLWithString:@"/unimplemented" relativeToURL:[BTOfflineModeURLProtocol clientApiBaseURL]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];

        OCMockObject<NSURLProtocolClient> *mockURLProtocolClient = [OCMockObject mockForProtocol:@protocol(NSURLProtocolClient)];

        BTOfflineModeURLProtocol *offlineURLProtocol = [[BTOfflineModeURLProtocol alloc] initWithRequest:request cachedResponse:nil client:mockURLProtocolClient];

        [mockURLProtocolClient setExpectationOrderMatters:YES];
        [[mockURLProtocolClient expect] URLProtocol:offlineURLProtocol didReceiveResponse:[OCMArg checkWithBlock:^BOOL(NSHTTPURLResponse *response) {
            return response.statusCode == 501;
        }] cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [[mockURLProtocolClient expect] URLProtocolDidFinishLoading:offlineURLProtocol];

        [offlineURLProtocol startLoading];

        [mockURLProtocolClient verify];
    });
});

SpecEnd
