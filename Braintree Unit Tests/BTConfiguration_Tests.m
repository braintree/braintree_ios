#import <XCTest/XCTest.h>
#import "BTConfiguration_Internal.h"

#import "BTHTTP.h"
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

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConfigurationHasAKey {
    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key"];
    XCTAssertEqualObjects(configuration.clientKey, @"test-client-key");
}

- (void)testConfigurationCanGetRemoteConfiguration {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key"];

    FakeHTTP *fake = [[FakeHTTP alloc] init];
    // TODO: Change the expected url to be based on the merchant and environment parsed out of the client key
    [fake expectGETRequestToEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"test": @YES }];

    configuration.configurationHttp = fake;

    [configuration fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        XCTAssertEqual(fake.requestCount, 1);
        XCTAssertTrue(remoteConfiguration[@"test"].isTrue);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testConfigurationCanFailWhenTheServerRespondsWithANon200StatusCode {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key"];

    FakeHTTP *fake = [[FakeHTTP alloc] init];
    [fake expectGETRequestToEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"error_message": @"Something bad happened" } statusCode:503];

    configuration.configurationHttp = fake;

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

    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key"];

    FakeHTTP *fake = [[FakeHTTP alloc] init];
    NSError *anError = [NSError errorWithDomain:NSURLErrorDomain
                                           code:NSURLErrorCannotConnectToHost
                                       userInfo:nil];
    [fake expectGETRequestToEndpoint:@"/client_api/v1/configuration" respondWithError:anError];

    configuration.configurationHttp = fake;

    [configuration fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        XCTAssertEqual(fake.requestCount, 1);
        XCTAssertNil(remoteConfiguration);
        XCTAssertEqual(error, anError);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testSerialInvocationsOfFetchConfigurationPerformOnlyOneRequest {
    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key"];

    FakeHTTP *fake = [[FakeHTTP alloc] init];
    // TODO: Change the expected url to be based on the merchant and environment parsed out of the client key
    [fake expectGETRequestToEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"test": @YES }];
    configuration.configurationHttp = fake;

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

#pragma mark Dispatch Queue

- (void)testDispatchQueueMainQueueByDefault {
    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key"];

    XCTAssertEqualObjects(configuration.dispatchQueue, dispatch_get_main_queue());
}

- (void)testDispatchQueueMainQueueByDefaultWhenNilSpecified {
    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key" dispatchQueue:nil];

    XCTAssertEqualObjects(configuration.dispatchQueue, dispatch_get_main_queue());
}

- (void)testDispatchQueueRetainedWhenSpecified {
    dispatch_queue_t q = dispatch_queue_create("com.braintreepayments.BTConfiguration_Tests.testDispatchQueueRetainedWhenSpecified", DISPATCH_QUEUE_SERIAL);
    BTConfiguration *configuration = [[BTConfiguration alloc] initWithClientKey:@"test-client-key" dispatchQueue:q];

    XCTAssertEqualObjects(configuration.dispatchQueue, q);
}


@end
