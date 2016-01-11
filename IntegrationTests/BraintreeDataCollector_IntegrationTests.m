#import "BraintreeDataCollector.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface BraintreeDataCollector_IntegrationTests : XCTestCase
@property (nonatomic, strong) BTDataCollector *data;
@end

@implementation BraintreeDataCollector_IntegrationTests

- (void)setUp {
    [super setUp];
    
    self.data = [[BTDataCollector alloc] initWithEnvironment:BTDataCollectorEnvironmentSandbox];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - collectFraudData:

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)testCollectFraudData_returnsFraudData {
    id delegate = OCMProtocolMock(@protocol(BTDataCollectorDelegate));
    self.data.delegate = delegate;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    OCMStub([delegate dataCollectorDidComplete:self.data]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });

    NSString *deviceData = [self.data collectFraudData];
    
    XCTAssertTrue([deviceData containsString:@"correlation_id"]);
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testCollectCardFraudData_returnsFraudDataWithNoPayPalFraudData {
    id delegate = OCMProtocolMock(@protocol(BTDataCollectorDelegate));
    self.data.delegate = delegate;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    OCMStub([delegate dataCollectorDidComplete:self.data]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });
    
    NSString *deviceData = [self.data collectCardFraudData];
    
    XCTAssertNotNil(deviceData);
    XCTAssertFalse([deviceData containsString:@"correlation_id"]);
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

#pragma clang diagnostic pop

- (void)testCollectPayPalClientMetadataId_returnsClientMetadataId {
    id delegate = OCMProtocolMock(@protocol(BTDataCollectorDelegate));
    self.data.delegate = delegate;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    OCMStub([delegate dataCollectorDidComplete:self.data]).andDo(^(__unused NSInvocation *invocation) {
        [expectation fulfill];
    });
    
    XCTAssertNotNil([self.data collectPayPalClientMetadataId]);
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}


@end
