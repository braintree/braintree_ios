#import <XCTest/XCTest.h>
#import "BTConfiguration_Internal.h"
#import "BTHTTP.h"
#import "BTHTTPTestProtocol.h"

@interface FakeHTTP : BTHTTP

@property (nonatomic, assign) NSUInteger requestCount;

@property (nonatomic, copy) NSString *expectedEndpoint;
@property (nonatomic, strong) BTJSON *cannedResponse;
@property (nonatomic, assign) NSUInteger cannedStatusCode;
@property (nonatomic, strong) NSError *cannedError;

@end

@implementation FakeHTTP

- (void)expectGETRequestToEndpoint:(NSString *)endpoint respondWith:(id)value {
    [self expectGETRequestToEndpoint:endpoint respondWith:value statusCode:200];
}

- (void)expectGETRequestToEndpoint:(NSString *)endpoint respondWith:(id)value statusCode:(NSUInteger)statusCode {
    self.expectedEndpoint = endpoint;
    self.cannedResponse = [[BTJSON alloc] initWithValue:value];
    self.cannedStatusCode = statusCode;
}

- (void)expectGETRequestToEndpoint:(NSString *)endpoint respondWithError:(NSError *)error {
    self.expectedEndpoint = endpoint;
    self.cannedError = error;
}

- (void)GET:(NSString *)url parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {
    self.requestCount++;
    if (self.cannedError) {
        completionBlock(nil, nil, self.cannedError);
    } else {
        NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url]
                                                                      statusCode:self.cannedStatusCode
                                                                     HTTPVersion:nil
                                                                    headerFields:nil];
        completionBlock(self.cannedResponse, httpResponse, nil);
    }
}

@end

@interface BTConfiguration_Tests : XCTestCase
@end

@implementation BTConfiguration_Tests

- (void)testConfigurationHasAKey {
    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key" error:NULL];
    XCTAssertEqualObjects(configuration.clientKey, @"test-client-key");
}

- (void)testClientApiHTTP_infersBaseURLFromClientKey_sandbox {
    XCTestExpectation *expectation = [self expectationWithDescription:@"HTTP Response"];
    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"sandbox_stuff_test_merchant_id" error:NULL];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    [sessionConfiguration setProtocolClasses:@[[BTHTTPTestProtocol class]]];
    configuration.clientApiHTTP.session = [NSURLSession sessionWithConfiguration:sessionConfiguration];

    [configuration.clientApiHTTP GET:@"foo" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        NSURLRequest *request = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
        XCTAssertEqualObjects(request.URL.absoluteString, @"https://sandbox.braintreegateway.com/merchants/test_merchant_id/client_api/foo?authorization_fingerprint=sandbox_stuff_test_merchant_id");

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testConfigurationCanGetRemoteConfiguration {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key" error:NULL];

    FakeHTTP *fake = [[FakeHTTP alloc] init];
    // TODO: Change the expected url to be based on the merchant and environment parsed out of the client key
    [fake expectGETRequestToEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"test": @YES }];

    configuration.clientApiHTTP = fake;

    [configuration fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        XCTAssertEqual(fake.requestCount, 1);
        XCTAssertTrue(remoteConfiguration[@"test"].isTrue);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testConfigurationCanFailWhenTheServerRespondsWithANon200StatusCode {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key" error:NULL];

    FakeHTTP *fake = [[FakeHTTP alloc] init];
    [fake expectGETRequestToEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"error_message": @"Something bad happened" } statusCode:503];

    configuration.clientApiHTTP = fake;

    [configuration fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        XCTAssertEqual(fake.requestCount, 1);
        XCTAssertNil(remoteConfiguration);
        XCTAssertEqualObjects(error.domain, BTConfigurationErrorDomain);
        XCTAssertEqual(error.code, BTConfigurationErrorCodeConfigurationUnavailable);
        XCTAssertEqualObjects(error.localizedFailureReason, @"Unable to fetch remote configuration from Braintree API at this time.");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testConfigurationFailsWhenNetworkHasError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key" error:NULL];

    FakeHTTP *fake = [[FakeHTTP alloc] init];
    NSError *anError = [NSError errorWithDomain:NSURLErrorDomain
                                           code:NSURLErrorCannotConnectToHost
                                       userInfo:nil];
    [fake expectGETRequestToEndpoint:@"/client_api/v1/configuration" respondWithError:anError];

    configuration.clientApiHTTP = fake;

    [configuration fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        XCTAssertEqual(fake.requestCount, 1);
        XCTAssertNil(remoteConfiguration);
        XCTAssertEqual(error, anError);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testSerialInvocationsOfFetchConfigurationPerformOnlyOneRequest {
    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key" error:NULL];

    FakeHTTP *fake = [[FakeHTTP alloc] init];
    [fake expectGETRequestToEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"test": @YES }];
    configuration.clientApiHTTP = fake;

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"First fetch configuration"];

    [configuration fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        XCTAssertEqual(fake.requestCount, 1);
        XCTAssertTrue(remoteConfiguration[@"test"].isTrue);

        [expectation1 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Second fetch configuration"];
    [configuration fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        XCTAssertEqual(fake.requestCount, 1);
        XCTAssertTrue(remoteConfiguration[@"test"].isTrue);

        [expectation2 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInitialization_withInvalidClientKey_returnsError {
//    BTConfiguration *configuration = [BTConfiguration alloc] initWithClientKey:<#(nonnull NSString *)#> dispatchQueue:<#(nullable dispatch_queue_t)#> error:<#(NSError * __nullable __autoreleasing * __nullable)#>
    XCTFail();
}

#pragma mark Dispatch Queue

- (void)testDispatchQueueMainQueueByDefault {
    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key" error:NULL];

    XCTAssertEqualObjects(configuration.dispatchQueue, dispatch_get_main_queue());
}

- (void)testDispatchQueueMainQueueByDefaultWhenNilSpecified {
    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key" dispatchQueue:nil error:NULL];

    XCTAssertEqualObjects(configuration.dispatchQueue, dispatch_get_main_queue());
}

- (void)testDispatchQueueRetainedWhenSpecified {
    dispatch_queue_t q = dispatch_queue_create("com.braintreepayments.BTConfiguration_Tests.testDispatchQueueRetainedWhenSpecified", DISPATCH_QUEUE_SERIAL);
    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key" dispatchQueue:q error:NULL];

    XCTAssertEqualObjects(configuration.dispatchQueue, q);
}


@end
