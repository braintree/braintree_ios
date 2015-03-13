#import "BTHTTP.h"

SpecBegin(BTHTTPSSLPinning)

describe(@"SSL Pinning", ^{
#ifdef RUN_SSL_PINNING_SPECS
    it(@"trusts pinned root certificates", ^{
        waitUntil(^(DoneCallback done){
            NSURL *url = [NSURL URLWithString:@"https://localhost:9443"];
            BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url];
            http.pinnedCertificates = @[[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"good_root_cert" ofType:@"der"]]];

            [http GET:@"/" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response.isSuccess).to.beTruthy();
                expect(error).to.beNil();
                done();
            }];
        });
    });

    it(@"rejects an untrusted (unpinned) root certificates from otherwise legitimate hosts", ^{
        waitUntil(^(DoneCallback done){
            NSURL *url = [NSURL URLWithString:@"https://localhost:9444"];
            BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url];
            http.pinnedCertificates = @[[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"good_root_cert" ofType:@"der"]]];

            [http GET:@"heartbeat" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response.isSuccess).to.beFalsy();
                expect(error).to.beKindOf([NSError class]);
                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                expect(error.code).to.equal(BTServerErrorSSL);

                expect([error.userInfo[NSUnderlyingErrorKey] domain]).to.equal(NSURLErrorDomain);
                expect([error.userInfo[NSUnderlyingErrorKey] code]).to.equal(NSURLErrorServerCertificateUntrusted);

                done();
            }];
        });
    });

    it(@"allows non-SSL http requests", ^{
        waitUntil(^(DoneCallback done){
            NSURL *url = [NSURL URLWithString:@"http://localhost:9445/"];
            BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url];

            [http GET:@"heartbeat" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response.isSuccess).to.beTruthy();
                expect(error).to.beNil();

                done();
            }];
        });
    });
#else
    pending(@"specs only pass when the test https server (https_server.rb) is running");
#endif

    it(@"trusts the production ssl certificates", ^{
        waitUntil(^(DoneCallback done){
            NSURL *url   = [NSURL URLWithString:@"https://api.braintreegateway.com"];
            BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url];

            [http GET:@"/heartbeat.json" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response.isSuccess).to.beTruthy();
                expect([response.object stringForKey:@"heartbeat"]).to.equal(@"d2765eaa0dad9b300b971f074-production");
                expect(error).to.beNil();
                done();
            }];
        });
    });

    it(@"trusts the sandbox ssl certificates", ^{
        waitUntil(^(DoneCallback done){
            NSURL *url   = [NSURL URLWithString:@"https://api.sandbox.braintreegateway.com"];
            BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url];

            [http GET:@"/heartbeat.json" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response.isSuccess).to.beTruthy();
                expect([response.object stringForKey:@"heartbeat"]).to.equal(@"d2765eaa0dad9b300b971f074-sandbox");
                expect(error).to.beNil();
                done();
            }];
        });
    });

    it(@"does not trust a valid certificate chain with a root ca we do not explicitly trust", ^{
        waitUntil(^(DoneCallback done){
            NSURL *url   = [NSURL URLWithString:@"https://www.digicert.com"];
            BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url];

            [http GET:@"/" parameters:nil completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response).to.beNil();
                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                expect(error.code).to.equal(BTServerErrorSSL);
                done();
            }];
        });
    });
});

SpecEnd
