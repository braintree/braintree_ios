#import "AFSecurityPolicy.h"
#import "BTHTTP.h"

SpecBegin(BTHTTP)

describe(@"SSL Pinning", ^{
    it(@"trusts pinned root certificates", ^AsyncBlock{
        NSURL *url = [NSURL URLWithString:@"https://localhost:9443"];
        BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url];
        http.pinnedCertificates = @[[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"good_root_cert" ofType:@"der"]]];

        [http GET:@"/" completion:^(BTHTTPResponse *response, NSError *error) {
            expect(response.isSuccess).to.beTruthy();
            expect(error).to.beNil();
            done();
        }];
    });

    it(@"rejects an untrusted (unpinned) root certificates from otherwise legitimate hosts", ^AsyncBlock{
        NSURL *url = [NSURL URLWithString:@"https://localhost:9444"];
        BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url];
        http.pinnedCertificates = @[[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"good_root_cert" ofType:@"der"]]];

        [http GET:@"heartbeat" completion:^(BTHTTPResponse *response, NSError *error) {
            expect(response.isSuccess).to.beFalsy();
            expect(error).to.beKindOf([NSError class]);
            expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            expect(error.code).to.equal(BTServerErrorSSL);

            expect([error.userInfo[NSUnderlyingErrorKey] domain]).to.equal(NSURLErrorDomain);
            expect([error.userInfo[NSUnderlyingErrorKey] code]).to.equal(NSURLErrorUserCancelledAuthentication);

            done();
        }];
    });

    it(@"allows non-SSL http requests", ^AsyncBlock{
        NSURL *url = [NSURL URLWithString:@"http://localhost:9445/"];
        BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url];

        [http GET:@"heartbeat" completion:^(BTHTTPResponse *response, NSError *error) {
            expect(response.isSuccess).to.beTruthy();
            expect(error).to.beNil();

            done();
        }];
    });

    pending(@"gateway changes to support JSON heartbeats", ^{
        describe(@"the default installed certificates", ^{
            it(@"trusts the production ssl certificates", ^AsyncBlock{
                NSURL *url   = [NSURL URLWithString:@"https://api.braintreegateway.com"];
                BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url];

                [http GET:@"/" completion:^(BTHTTPResponse *response, NSError *error) {
                    expect(response.isSuccess).to.beTruthy();
                    expect(error).to.beNil();
                    done();
                }];
            });

            it(@"trusts the sandbox ssl certificates", ^AsyncBlock{
                NSURL *url   = [NSURL URLWithString:@"https://api.sandbox.braintreegateway.com"];
                BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url];

                [http GET:@"/" completion:^(BTHTTPResponse *response, NSError *error) {
                    expect(response.isSuccess).to.beTruthy();
                    expect(error).to.beNil();
                    done();
                }];
            });
        });
    });
});

SpecEnd
