#import "BraintreeFraud.h"
#import <XCTest/XCTest.h>

@interface BraintreeFraud_IntegrationTests : XCTestCase
@property (nonatomic, strong) BTFraudData *data;
@end

@implementation BraintreeFraud_IntegrationTests

- (void)setUp {
    [super setUp];
    
    self.data = [[BTFraudData alloc] initWithEnvironment:BTFraudDataEnvironmentSandbox];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - collectFraudData:

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)testCollectFraudData_returnsFraudData {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [self.data collectFraudData:^(NSString * _Nullable deviceData, NSError * _Nullable error) {
        XCTAssertTrue([deviceData containsString:@"correlation_id"]);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testCollectCardFraudData_returnsFraudDataWithNoPayPalFraudData {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [self.data collectCardFraudData:^(NSString * _Nullable deviceData, NSError * _Nullable error) {
        XCTAssertNotNil(deviceData);
        XCTAssertFalse([deviceData containsString:@"correlation_id"]);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma clang diagnostic pop

- (void)testPayPalFraudID_returnsFraudID {
    XCTAssertNotNil([BTFraudData payPalFraudID]);
}


@end
