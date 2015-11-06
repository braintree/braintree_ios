#import <BraintreeCore/BTTokenizationService.h>
#import <XCTest/XCTest.h>

@interface BTTokenizationService_Tests : XCTestCase

@end

@implementation BTTokenizationService_Tests {
    BTTokenizationService *service;
}

- (void)setUp {
    [super setUp];
    service = [BTTokenizationService sharedService];
}

- (void)testRegisterType_addsTypeToTypes {
    [service registerType:@"MyType" withTokenizationBlock:^(__unused BTAPIClient *apiClient, __unused NSDictionary *options, __unused void (^completionBlock)(BTPaymentMethodNonce *paymentMethodNonce, NSError *error)) {
    }];

    XCTAssertTrue([service.allTypes containsObject:@"MyType"]);
}

- (void)testAllTypes_whenTypeIsNotRegistered_doesntContainType {
    XCTAssertFalse([service.allTypes containsObject:@"MyType"]);
}

- (void)testIsTypeAvailable_whenTypeIsRegistered_isTrue {
    [service registerType:@"MyType" withTokenizationBlock:^(__unused BTAPIClient *apiClient, __unused NSDictionary *options, __unused void (^completionBlock)(BTPaymentMethodNonce *paymentMethodNonce, NSError *error)) {
    }];

    XCTAssertTrue([service isTypeAvailable:@"MyType"]);
}

- (void)testIsTypeAvailable_whenTypeIsNotRegistered_isFalse {
    XCTAssertFalse([service isTypeAvailable:@"TypeThatHasntBeenRegistered"]);
}

- (void)testTokenizeType_whenTypeIsRegistered_callsTokenizationBlock {
    XCTestExpectation *expectation = [self expectationWithDescription:@"tokenization block called"];
    [service registerType:@"MyType" withTokenizationBlock:^(__unused BTAPIClient *apiClient, __unused NSDictionary *options, __unused void (^completionBlock)(BTPaymentMethodNonce *paymentMethodNonce, NSError *error)) {
        [expectation fulfill];
    }];
    [service tokenizeType:@"MyType" withAPIClient:[[BTAPIClient alloc] initWithAuthorization:@"test_key"] completion:^(__unused BTPaymentMethodNonce *  _Nonnull paymentMethodNonce, __unused NSError * _Nonnull error) {
    }];
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testTokenizeType_whenTypeIsRegistered_callsTokenizationBlockWithOptions {
    XCTestExpectation *expectation = [self expectationWithDescription:@"tokenization block called"];
    [service registerType:@"MyType" withTokenizationBlock:^(__unused BTAPIClient *apiClient, NSDictionary *options, __unused void (^completionBlock)(BTPaymentMethodNonce *paymentMethodNonce, NSError *error)) {
        XCTAssertEqualObjects(@{@"Some Custom Option Key": @"The Option Value"}, options);
        [expectation fulfill];
    }];
    [service tokenizeType:@"MyType" options:@{@"Some Custom Option Key": @"The Option Value"} withAPIClient:[[BTAPIClient alloc] initWithAuthorization:@"test_key"] completion:^(__unused BTPaymentMethodNonce * _Nonnull paymentMethodNonce, __unused NSError * _Nonnull error) {
    }];
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testTokenizeType_whenTypeIsNotRegistered_returnsError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked"];
    [service tokenizeType:@"TypeThatHasntBeenRegistered" withAPIClient:[[BTAPIClient alloc] initWithAuthorization:@"test_key"] completion:^(BTPaymentMethodNonce *  _Nonnull paymentMethodNonce, NSError * _Nonnull error) {
        XCTAssertNil(paymentMethodNonce);
        XCTAssertEqualObjects(error.domain, BTTokenizationServiceErrorDomain);
        XCTAssertEqual(error.code, BTTokenizationServiceErrorTypeNotRegistered);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

@end
