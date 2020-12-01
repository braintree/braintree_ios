#import "BTHTTP.h"
#import "BTAPIHTTP.h"
#import <BraintreeCore/BTJSON.h>
#import <XCTest/XCTest.h>

@interface BTHTTP_SSLPinning_IntegrationTests : XCTestCase
@end

@implementation BTHTTP_SSLPinning_IntegrationTests

// Will work when we comply with ATS
- (void)testBTHTTP_whenUsingProductionEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication {
    NSURL *url = [NSURL URLWithString:@"https://api.braintreegateway.com"];
    BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url tokenizationKey:@"development_testing_integration_merchant_id"];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [http GET:@"/heartbeat.json" completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
        XCTAssertEqualObjects([body[@"heartbeat"] asString], @"d2765eaa0dad9b300b971f074-production");
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testBTHTTP_whenUsingSandboxEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication {
    NSURL *url = [NSURL URLWithString:@"https://api.sandbox.braintreegateway.com"];
    BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url tokenizationKey:@"development_testing_integration_merchant_id"];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [http GET:@"/heartbeat.json" completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
        XCTAssertEqualObjects([body[@"heartbeat"] asString], @"d2765eaa0dad9b300b971f074-sandbox");
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testBTHTTP_whenUsingProductionEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI {
    NSURL *url = [NSURL URLWithString:@"https://payments.braintree-api.com"];
    BTAPIHTTP *http = [[BTAPIHTTP alloc] initWithBaseURL:url accessToken:@""];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [http GET:@"/ping" completion:^(__unused BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testBTHTTP_whenUsingSandboxEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI {
    NSURL *url = [NSURL URLWithString:@"https://payments.sandbox.braintree-api.com"];
    BTAPIHTTP *http = [[BTAPIHTTP alloc] initWithBaseURL:url accessToken:@""];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [http GET:@"/ping" completion:^(__unused BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testBTHTTP_whenUsingAServerWithValidCertificateChainWithARootCAThatWeDoNotExplicitlyTrust_doesNotAllowNetworkCommunication {
    NSURL *url = [NSURL URLWithString:@"https://www.globalsign.com"];
    BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:url tokenizationKey:@"development_testing_integration_merchant_id"];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [http GET:@"/heartbeat.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNil(body);
        XCTAssertNil(response);
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, NSURLErrorServerCertificateUntrusted);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
