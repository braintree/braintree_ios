#import "BraintreeDataCollector/BraintreeDataCollector-Swift.h"
#import "BraintreeCore/BTAPIClient.h"
#import "KDataCollector.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface BraintreeDataCollector_IntegrationTests : XCTestCase
@property (nonatomic, strong) BTDataCollector *dataCollector;
@end

@implementation BraintreeDataCollector_IntegrationTests

- (void)setUp {
    [super setUp];
    BTAPIClient *client = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY];
    self.dataCollector = [[BTDataCollector alloc] initWithAPIClient:client];
}

- (void)tearDown {
    [super tearDown];
    self.dataCollector = nil;
}

#pragma mark - collectDeviceData:

- (void)testCollectDeviceData_returnsAllFraudData {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    
    [self.dataCollector collectDeviceData:^(NSString * _Nullable deviceData, NSError * _Nullable error) {
        XCTAssertTrue([deviceData containsString:@"correlation_id"]);
        XCTAssertTrue([deviceData containsString:@"device_session_id"]);
        XCTAssertTrue([deviceData containsString:@"fraud_merchant_id"]);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end
