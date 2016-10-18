#import "BraintreeDataCollector.h"
#import "KDataCollector.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface BraintreeDataCollector_IntegrationTests : XCTestCase
@property (nonatomic, strong) BTDataCollector *dataCollector;
@end

@implementation BraintreeDataCollector_IntegrationTests

- (void)setUp {
    [super setUp];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.dataCollector = [[BTDataCollector alloc] initWithEnvironment:BTDataCollectorEnvironmentSandbox];
}

#pragma mark - collectFraudData:

- (void)testCollectFraudData_returnsFraudData {
    id delegate = OCMProtocolMock(@protocol(BTDataCollectorDelegate));
    self.dataCollector.delegate = delegate;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    OCMStub([delegate dataCollectorDidComplete:self.dataCollector]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });

    NSString *deviceData = [self.dataCollector collectFraudData];
    
    XCTAssertTrue([deviceData containsString:@"correlation_id"]);
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

// Test is failing because sandbox test merchant is configured with a Kount merchant ID that causes Kount to error.
- (void)pendCollectFraudDataWithCallback_returnsFraudData {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY];
    self.dataCollector = [[BTDataCollector alloc] initWithAPIClient:apiClient];
    id delegate = OCMProtocolMock(@protocol(BTDataCollectorDelegate));
    self.dataCollector.delegate = delegate;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delegate received completion callback"];
    OCMStub([delegate dataCollectorDidComplete:self.dataCollector]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });

    XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"Callback invoked"];
    [self.dataCollector collectFraudData:^(NSString * _Nonnull deviceData) {
        XCTAssertTrue([deviceData containsString:@"correlation_id"]);
        [callbackExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

// Test is failing because sandbox test merchant is configured with a Kount merchant ID that causes Kount to error.
- (void)pendCollectCardFraudDataWithCallback_returnsFraudDataWithNoPayPalFraudData {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY];
    self.dataCollector = [[BTDataCollector alloc] initWithAPIClient:apiClient];

    id delegate = OCMProtocolMock(@protocol(BTDataCollectorDelegate));
    self.dataCollector.delegate = delegate;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delegate received completion callback"];
    OCMStub([delegate dataCollectorDidComplete:self.dataCollector]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });

    XCTestExpectation *callbackExpectation = [self expectationWithDescription:@"Callback invoked"];
    [self.dataCollector collectCardFraudData:^(NSString * _Nonnull deviceData) {
        XCTAssertNotNil(deviceData);
        XCTAssertFalse([deviceData containsString:@"correlation_id"]);
        [callbackExpectation fulfill];
    }];
    

    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testCollectCardFraudData_returnsFraudDataWithNoPayPalFraudData {
    id delegate = OCMProtocolMock(@protocol(BTDataCollectorDelegate));
    self.dataCollector.delegate = delegate;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    OCMStub([delegate dataCollectorDidComplete:self.dataCollector]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });
    
    NSString *deviceData = [self.dataCollector collectCardFraudData];
    
    XCTAssertNotNil(deviceData);
    XCTAssertFalse([deviceData containsString:@"correlation_id"]);
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testCollectCardFraudData_whenMerchantIDIsInvalid_invokesErrorCallback {
    id delegate = OCMProtocolMock(@protocol(BTDataCollectorDelegate));
    self.dataCollector.delegate = delegate;
    [self.dataCollector setFraudMerchantId:@"-1"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Error callback invoked"];
    OCMStub([delegate dataCollector:self.dataCollector didFailWithError:[OCMArg checkWithBlock:^BOOL(NSError *error) {
        XCTAssertEqualObjects(error.localizedDescription, @"Merchant ID formatted incorrectly.");
        XCTAssertEqual(error.code, (NSInteger)KDataCollectorErrorCodeBadParameter);
        return YES;
    }]]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });
    
    [self.dataCollector collectCardFraudData];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testCollectPayPalClientMetadataId_returnsClientMetadataId {
    id delegate = OCMProtocolMock(@protocol(BTDataCollectorDelegate));
    self.dataCollector.delegate = delegate;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    OCMStub([delegate dataCollectorDidComplete:self.dataCollector]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });
    
    XCTAssertNotNil([self.dataCollector collectPayPalClientMetadataId]);
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma clang diagnostic pop

@end
