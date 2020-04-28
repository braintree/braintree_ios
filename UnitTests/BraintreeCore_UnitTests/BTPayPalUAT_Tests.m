#import "UnitTests-Swift.h"
#import <XCTest/XCTest.h>
#import "BTPayPalUAT.h"

@interface BTPayPalUAT_ObjCTests : XCTestCase

@end

@implementation BTPayPalUAT_ObjCTests

// Swift creates an error object implicitly, so a nil error can only be tested in Objective C
- (void)testInitWithUATString_whenErrorIsNil_setsAuthorizationFingerprintAndConfigURL {
    NSDictionary *dict = @{@"iss": @"https://api.paypal.com",
                           @"external_ids": @[
                                   @"PayPal:fake-pp-merchant",
                                   @"Braintree:some-bt-merchant"
                           ]};

    NSString *uatString = [BTPayPalUATTestHelper encodeUAT:dict];

    BTPayPalUAT *uat = [[BTPayPalUAT alloc] initWithUATString:uatString error:nil];
    XCTAssertNotNil(uat);
    XCTAssertEqual(uat.token, uatString);
    XCTAssertEqualObjects(uat.configURL.absoluteString, @"https://api.braintreegateway.com:443/merchants/some-bt-merchant/client_api/v1/configuration");
}

@end
