#import "UnitTests-Swift.h"
#import <XCTest/XCTest.h>
#import "BTPayPalUAT.h"

@interface BTPayPalUAT_ObjCTests : XCTestCase

@end

@implementation BTPayPalUAT_ObjCTests

// Swift creates an error object implicitly, so a nil error can only be tested in Objective C
// TODO: - make sure this passes once PP UAT returns PayPal and Braintree URLs for each environment
- (void)testInitWithUATString_whenErrorIsNil_setsAuthorizationFingerprintAndConfigURL {
    NSDictionary *dict = @{@"iss": @"https://api.paypal.com",
                           @"braintreeURL": @"https://some-braintree-url.com",
                           @"external_ids": @[
                                   @"PayPal:fake-pp-merchant",
                                   @"Braintree:fake-bt-merchant"
                           ]};

    NSString *uatString = [BTPayPalUATTestHelper encodeUAT:dict];

    BTPayPalUAT *uat = [[BTPayPalUAT alloc] initWithUATString:uatString error:nil];
    XCTAssertNotNil(uat);
    XCTAssertEqual(uat.token, uatString);
    XCTAssertEqualObjects(uat.configURL.absoluteString, @"https://some-braintree-url.com/merchants/fake-bt-merchant/client_api/v1/configuration");
}

@end
