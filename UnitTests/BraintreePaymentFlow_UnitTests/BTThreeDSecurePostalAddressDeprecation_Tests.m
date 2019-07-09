#import <XCTest/XCTest.h>
#import "BTThreeDSecurePostalAddress.h"

@interface BTThreeDSecurePostalAddressDeprecation_Tests : XCTestCase

@end

@implementation BTThreeDSecurePostalAddressDeprecation_Tests

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

// This test is in Objective-C because there is currently no way to supress deprecation warnings in Swift
- (void)testDeprecatedNameProperties {
    BTThreeDSecurePostalAddress *address = [BTThreeDSecurePostalAddress new];
    address.firstName = @"Jane";
    address.lastName = @"Girl";

    XCTAssertEqual(address.givenName, @"Jane");
    XCTAssertEqual(address.firstName, @"Jane");
    XCTAssertEqual(address.surname, @"Girl");
    XCTAssertEqual(address.lastName, @"Girl");
}

#pragma clang diagnostic pop

@end
