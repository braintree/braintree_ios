
#import "BTHTTP.h"
#import "BTSpecHelper.h"

#define kBTHTTPTestProtocolScheme @"bt-http-test"
#define kBTHTTPTestProtocolHost @"1.2.3"

@interface BTHTTPTestProtocol : NSURLProtocol
@end

@implementation BTHTTPTestProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {

    BOOL hasCorrectScheme = [request.URL.scheme isEqualToString:kBTHTTPTestProtocolScheme];
    BOOL hasCorrectHost = [request.URL.host isEqualToString:kBTHTTPTestProtocolHost];

    return hasCorrectScheme && hasCorrectHost;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    id<NSURLProtocolClient> client = self.client;

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{@"Content-Type": @"application/json"}];

    [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];

    [client URLProtocol:self didLoadData:[@"{\"hello\": \"world\"}" dataUsingEncoding:NSUTF8StringEncoding]];

    [client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}

@end


SpecBegin(BTHTTP)

describe(@"protocolClasses property", ^{
    it(@"can be set", ^{
        NSURL *url = [[NSURL alloc] init];
        BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url];
        [http setProtocolClasses:@[[BTHTTPTestProtocol class]]];
    });

    it(@"successfully intercepts requests", ^AsyncBlock{
        BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:({
            NSURLComponents *components = [[NSURLComponents alloc] init];
            components.scheme = kBTHTTPTestProtocolScheme;
            components.host = kBTHTTPTestProtocolHost;
            components.URL;
        })];

        [http GET:@"/" completion:^(BTHTTPResponse *response, NSError *error) {
            expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            expect(error.code).to.equal(BTServerErrorNetworkUnavailable);

            [http setProtocolClasses:@[[BTHTTPTestProtocol class]]];

            [http GET:@"/" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(error).to.beNil();
                expect(response.object[@"hello"]).to.equal(@"world");
                done();
            }];

        }];

    });
});

SpecEnd