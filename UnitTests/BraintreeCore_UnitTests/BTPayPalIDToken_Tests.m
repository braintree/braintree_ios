#import "UnitTests-Swift.h"
#import <XCTest/XCTest.h>
#import "BTPayPalIDToken.h"

@interface BTPayPalIDToken_ObjCTests : XCTestCase

@end

@implementation BTPayPalIDToken_ObjCTests

// Swift creates an error object implicitly, so a nil error can only be tested in Objective C
- (void)testInitWithIDTkenString_whenErrorIsNil_setsAuthorizationFingerprintAndConfigURL {
    NSDictionary *dict = @{@"iss": @"https://api.paypal.com",
                           @"external_id": @[
                                   @"PayPal:fake-pp-merchant",
                                   @"Braintree:some-bt-merchant"
                           ]};

    NSString *idTokenString = [BTPayPalIDTokenTestHelper encodeIDToken:dict];

    BTPayPalIDToken *idToken = [[BTPayPalIDToken alloc] initWithIDTokenString:idTokenString error:nil];
    XCTAssertNotNil(idToken);
    XCTAssertEqual(idToken.token, idTokenString);
    XCTAssertEqualObjects(idToken.configURL.absoluteString, @"https://api.braintreegateway.com:443/merchants/some-bt-merchant/client_api/v1/configuration");
}

@end
