#import "BraintreeDataCollector.h"
#import "DeviceCollectorSDK.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface BraintreeDataCollector_IntegrationTests : XCTestCase
@property (nonatomic, strong) BTDataCollector *dataCollector;
@end

@implementation BraintreeDataCollector_IntegrationTests

- (void)setUp {
    [super setUp];
    
    self.dataCollector = [[BTDataCollector alloc] initWithEnvironment:BTDataCollectorEnvironmentSandbox];
}

#pragma mark - collectFraudData:

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

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

- (void)testCollectCardFraudData_whenCollectorURLIsInvalid_invokesErrorCallback {
    id delegate = OCMProtocolMock(@protocol(BTDataCollectorDelegate));
    self.dataCollector.delegate = delegate;
    [self.dataCollector setCollectorUrl:@"fake url that should fail"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Error callback invoked"];
    OCMStub([delegate dataCollector:self.dataCollector didFailWithError:[OCMArg checkWithBlock:^BOOL(NSError *error) {
        XCTAssertEqualObjects(error.domain, @"URL validation failed");
        XCTAssertEqual(error.code, (NSInteger)DC_ERR_INVALID_URL);
        return YES;
    }]]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });
    
    [self.dataCollector collectCardFraudData];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testCollectCardFraudData_whenMerchantIDIsInvalid_invokesErrorCallback {
    id delegate = OCMProtocolMock(@protocol(BTDataCollectorDelegate));
    self.dataCollector.delegate = delegate;
    [self.dataCollector setFraudMerchantId:@"fake merchant id which should fail"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Error callback invoked"];
    OCMStub([delegate dataCollector:self.dataCollector didFailWithError:[OCMArg checkWithBlock:^BOOL(NSError *error) {
        XCTAssertEqualObjects(error.domain, @"Merchant ID validation failed");
        XCTAssertEqual(error.code, (NSInteger)DC_ERR_INVALID_MERCHANT);
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
