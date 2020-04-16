#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <XCTest/XCTest.h>

@interface BTAPIClient_IntegrationTests : XCTestCase
@end

@implementation BTAPIClient_IntegrationTests

- (void)testFetchConfiguration_withTokenizationKey_returnsTheConfiguration {
    BTAPIClient *client = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [client fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertEqualObjects([configuration.json[@"merchantId"] asString], @"dcpspy2brwdjr3qn");
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFetchConfiguration_withClientToken_returnsTheConfiguration {
    BTAPIClient *client = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [client fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        // Note: client token uses a different merchant ID than the merchant whose tokenization key
        // we use in the other test
        XCTAssertEqualObjects([configuration.json[@"merchantId"] asString], @"348pk9cgf3bgyw2b");
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFetchConfiguration_withVersionThreeClientToken_returnsTheConfiguration {
    BTAPIClient *client = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN_VERSION_3];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [client fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        // Note: client token uses a different merchant ID than the merchant whose tokenization key
        // we use in the other test
        XCTAssertEqualObjects([configuration.json[@"merchantId"] asString], @"dcpspy2brwdjr3qn");
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFetchConfiguration_withPayPalUAT_returnsTheConfiguration {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch UAT from PPCP sample server; then fetch BT config"];

    // NOTE: - This test needs to fetch an active PayPal UAT
    // Currently, the PP team cannot provide hard-coded UAT test values
    [self fetchPayPalUAT:^(NSString *uat, NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Error fetching a UAT from https://ppcp-sample-merchant-sand.herokuapp.com");
        }

        BTAPIClient *client = [[BTAPIClient alloc] initWithAuthorization:uat];

        [client fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
            XCTAssertEqualObjects([configuration.json[@"merchantId"] asString], @"cfxs3ghzwfk2rhqm");
            XCTAssertEqualObjects([configuration.json[@"environment"] asString], @"sandbox");
            XCTAssertEqualObjects([configuration.json[@"assetsUrl"] asString], @"https://assets.braintreegateway.com");
            XCTAssertNil(error);
            [expectation fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:20 handler:nil];
}

#pragma mark - Helpers

-(void)fetchPayPalUAT:(void (^)(NSString *uat, NSError * _Nullable error))completion {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://ppcp-sample-merchant-sand.herokuapp.com/uat?countryCode=US"]];

    [urlRequest setHTTPMethod:@"GET"];

    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

            completion(responseDictionary[@"universal_access_token"], parseError);
        }

        completion(nil, nil);
    }];

    [dataTask resume];
}

@end
