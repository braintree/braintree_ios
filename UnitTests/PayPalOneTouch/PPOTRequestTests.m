//
//  PPOTRequestTests.m
//  PayPalOneTouch
//
//  Copyright © 2016 PayPal, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PPOTRequestFactory.h"
#import "PPOTConfiguration.h"
#import "PPOTRequest_Internal.h"
#import "PPOTCheckoutRequest_Internal.h"
#import "PPOTSwitchRequest.h"

@interface PPOTRequestTests : XCTestCase

@end

@implementation PPOTRequestTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBaseOverrideURLJustPath {
    NSURL *originalApprovalURL = [NSURL URLWithString:@"https://example.com:8080/webscr/billingAgreement?token=TEST_TOKEN_VALUE&otherParam=1"];
    NSURL *actualURL = [self approvalURLWithBaseOverrideURL:@"/some/path" originalApprovalURL:originalApprovalURL];

    NSURL *expectedURL = [NSURL URLWithString:@"https://example.com:8080/some/path?token=TEST_TOKEN_VALUE&otherParam=1"];
    XCTAssertEqualObjects(actualURL, expectedURL);
}

- (void)testBaseOverrideURLJustPathWithEndingSlash {
    // expected to keep scheme, hostname, and port
    NSURL *originalApprovalURL = [NSURL URLWithString:@"https://example.com:8080/webscr/billingAgreement?token=TEST_TOKEN_VALUE&otherParam=1"];
    NSURL *actualURL = [self approvalURLWithBaseOverrideURL:@"/some/path/" originalApprovalURL:originalApprovalURL];

    NSURL *expectedURL = [NSURL URLWithString:@"https://example.com:8080/some/path/?token=TEST_TOKEN_VALUE&otherParam=1"];
    XCTAssertEqualObjects(actualURL, expectedURL);
}

- (void)testBaseOverrideURLJustPathWithOriginalHavingEndingSlash {
    // expected to keep scheme, hostname, and port
    NSURL *originalApprovalURL = [NSURL URLWithString:@"https://example.com:8080/webscr/billingAgreement/?token=TEST_TOKEN_VALUE&otherParam=1"];
    NSURL *actualURL = [self approvalURLWithBaseOverrideURL:@"/some/path" originalApprovalURL:originalApprovalURL];

    NSURL *expectedURL = [NSURL URLWithString:@"https://example.com:8080/some/path?token=TEST_TOKEN_VALUE&otherParam=1"];
    XCTAssertEqualObjects(actualURL, expectedURL);
}

- (void)testBaseOverrideURLJustSchemeAndPath {
    // expected to keep hostname and port
    NSURL *originalApprovalURL = [NSURL URLWithString:@"https://example.com:8080/webscr/billingAgreement?token=TEST_TOKEN_VALUE&otherParam=1"];
    NSURL *actualURL = [self approvalURLWithBaseOverrideURL:@"custom:///some/path" originalApprovalURL:originalApprovalURL];

    NSURL *expectedURL = [NSURL URLWithString:@"custom://example.com:8080/some/path?token=TEST_TOKEN_VALUE&otherParam=1"];
    XCTAssertEqualObjects(actualURL, expectedURL);
}

- (void)testBaseOverrideURLHTTPSAndPath {
    // expected to keep hostname and port
    NSURL *originalApprovalURL = [NSURL URLWithString:@"https://example.com:8080/webscr/billingAgreement?token=TEST_TOKEN_VALUE&otherParam=1"];
    NSURL *actualURL = [self approvalURLWithBaseOverrideURL:@"custom:///some/path" originalApprovalURL:originalApprovalURL];

    NSURL *expectedURL = [NSURL URLWithString:@"custom://example.com:8080/some/path?token=TEST_TOKEN_VALUE&otherParam=1"];
    XCTAssertEqualObjects(actualURL, expectedURL);
}

- (void)testBaseOverrideURLHostnameAndPath {
    // expected to keep scheme, hostname, and port
    NSURL *originalApprovalURL = [NSURL URLWithString:@"https://example.com:8080/webscr/billingAgreement?token=TEST_TOKEN_VALUE&otherParam=1"];
    NSURL *actualURL = [self approvalURLWithBaseOverrideURL:@"https://www.paypal.com/some/path" originalApprovalURL:originalApprovalURL];

    NSURL *expectedURL = [NSURL URLWithString:@"https://www.paypal.com:8080/some/path?token=TEST_TOKEN_VALUE&otherParam=1"];
    XCTAssertEqualObjects(actualURL, expectedURL);
}

- (void)testBaseOverrideURLSchemeHostnamePortAndPath {
    // expected to keep scheme, hostname, and port
    NSURL *originalApprovalURL = [NSURL URLWithString:@"https://example.com:8080/webscr/billingAgreement?token=TEST_TOKEN_VALUE&otherParam=1"];
    NSURL *actualURL = [self approvalURLWithBaseOverrideURL:@"https://www.paypal.com:80/some/path" originalApprovalURL:originalApprovalURL];

    NSURL *expectedURL = [NSURL URLWithString:@"https://www.paypal.com:80/some/path?token=TEST_TOKEN_VALUE&otherParam=1"];
    XCTAssertEqualObjects(actualURL, expectedURL);
}

- (void)testBaseOverrideURLSchemeNormalCaseSandbox {
    // expected to keep scheme, hostname, and port
    NSURL *originalApprovalURL = [NSURL URLWithString:@"https://www.sandbox.paypal.com/webscr/billingAgreement?token=TEST_TOKEN_VALUE&otherParam=1"];
    NSURL *actualURL = [self approvalURLWithBaseOverrideURL:@"/mobile/agreements" originalApprovalURL:originalApprovalURL];

    NSURL *expectedURL = [NSURL URLWithString:@"https://www.sandbox.paypal.com/mobile/agreements?token=TEST_TOKEN_VALUE&otherParam=1"];
    XCTAssertEqualObjects(actualURL, expectedURL);
}

- (void)testBaseOverrideURLSchemeNormalCaseProduction {
    // expected to keep scheme, hostname, and port
    NSURL *originalApprovalURL = [NSURL URLWithString:@"https://www.paypal.com/webscr/billingAgreement?token=TEST_TOKEN_VALUE&otherParam=1"];
    NSURL *actualURL = [self approvalURLWithBaseOverrideURL:@"/mobile/agreements" originalApprovalURL:originalApprovalURL];

    NSURL *expectedURL = [NSURL URLWithString:@"https://www.paypal.com/mobile/agreements?token=TEST_TOKEN_VALUE&otherParam=1"];
    XCTAssertEqualObjects(actualURL, expectedURL);
}

- (NSURL *)approvalURLWithBaseOverrideURL:(NSString *)baseOverrideURLString originalApprovalURL:(NSURL *)approvalURL {
    PPOTBillingAgreementRequest *billingAgreementRequest = [PPOTRequestFactory billingAgreementRequestWithApprovalURL:approvalURL
                                                                                                             clientID:@"testClientID"
                                                                                                          environment:PayPalEnvironmentProduction
                                                                                                    callbackURLScheme:@"com.braintreepayments.Demo.payments"];
    // If this is nil, then make sure the Hosting App for the test has a Info.plist which contains the callback URL scheme specified in the
    // callbackURLScheme parameter
    XCTAssertNotNil(billingAgreementRequest);
    XCTAssertEqualObjects(approvalURL, billingAgreementRequest.approvalURL);

    PPOTConfigurationRecipe *billingAgreementRecipe = [self recipeWithBaseOverrideURL:baseOverrideURLString];
    return [billingAgreementRequest approvalURLForConfigurationRecipe:billingAgreementRecipe];
}

- (PPOTConfigurationRecipe *)recipeWithBaseOverrideURL:(nonnull NSString *)baseOverrideURL {
    PPOTConfiguration *configuration = [PPOTConfiguration configurationWithDictionary:
                                        @{@"os": @"iOS",
                                          @"file_timestamp": @"2014-12-19T16:39:57-08:00",
                                          @"1.0": @{
                                                  @"billing_agreement_recipes_in_decreasing_priority_order": @[
                                                          @{
                                                              @"protocol": @"0",
                                                              @"target": @"browser",
                                                              @"environments": @{
                                                                  @"live": @{
                                                                      @"base_url_override": baseOverrideURL,
                                                                      }
                                                                  }
                                                              },
                                                          ],
                                                  }
                                          }];
    XCTAssertNotNil(configuration);
    XCTAssertNotNil(configuration.prioritizedBillingAgreementRecipes);
    XCTAssertEqual([configuration.prioritizedBillingAgreementRecipes count], (NSUInteger)1);
    return configuration.prioritizedBillingAgreementRecipes[0];
}

- (void)testURLIsNotChangedWithNoBaseURLOverrideForCheckoutRequest {
    NSURL *approvalURL = [NSURL URLWithString:@"https://example.com/webscr/checkout?token=TEST_TOKEN_VALUE&otherParam=1"];
    PPOTCheckoutRequest *checkoutRequest = [PPOTRequestFactory checkoutRequestWithApprovalURL:approvalURL
                                                                                     clientID:@"testClientID"
                                                                                  environment:@"sandbox"
                                                                            callbackURLScheme:@"com.braintreepayments.Demo.payments"];
    // If this is nil, then make sure the Hosting App for the test has a Info.plist which contains the callback URL scheme specified in the
    // callbackURLScheme parameter
    XCTAssertNotNil(checkoutRequest);
    XCTAssertEqualObjects(approvalURL, checkoutRequest.approvalURL);

    PPOTConfiguration *configuration = [PPOTConfiguration configurationWithDictionary:
                                        @{@"os": @"iOS",
                                          @"file_timestamp": @"2014-12-19T16:39:57-08:00",
                                          @"1.0": @{
                                                  @"checkout_recipes_in_decreasing_priority_order": @[
                                                          @{
                                                              @"target": @"browser",
                                                              @"protocol": @"0",
                                                              },
                                                          ],
                                                  }
                                          }];
    PPOTConfigurationCheckoutRecipe *checkoutRecipe = configuration.prioritizedCheckoutRecipes[0];

    PPOTSwitchRequest *switchRequest = [checkoutRequest getAppSwitchRequestForConfigurationRecipe:checkoutRecipe];
    NSURL *expectedURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                               approvalURL.absoluteString,
                                               @"&x-source=com.braintreepayments.Demo&x-success=com.braintreepayments.Demo.payments://onetouch/v1/success&x-cancel=com.braintreepayments.Demo.payments://onetouch/v1/cancel"]];
    XCTAssertEqualObjects(switchRequest.encodedURL, expectedURL);
}

- (void)testURLIsChangedWithBaseURLOverridePresentForCheckoutRequest {
    NSURL *approvalURL = [NSURL URLWithString:@"https://www.paypal.com/webscr/checkout?token=TEST_TOKEN_VALUE&otherParam=1"];
    PPOTCheckoutRequest *checkoutRequest = [PPOTRequestFactory checkoutRequestWithApprovalURL:approvalURL
                                                                                     clientID:@"testClientID"
                                                                                  environment:@"live"
                                                                            callbackURLScheme:@"com.braintreepayments.Demo.payments"];
    // If this is nil, then make sure the Hosting App for the test has a Info.plist which contains the callback URL scheme specified in the
    // callbackURLScheme parameter
    XCTAssertNotNil(checkoutRequest);
    XCTAssertEqualObjects(approvalURL, checkoutRequest.approvalURL);

    PPOTConfiguration *configuration = [PPOTConfiguration configurationWithDictionary:
                                        @{@"os": @"iOS",
                                          @"file_timestamp": @"2014-12-19T16:39:57-08:00",
                                          @"1.0": @{
                                                  @"checkout_recipes_in_decreasing_priority_order": @[
                                                          @{
                                                              @"target": @"browser",
                                                              @"protocol": @"0",
                                                              @"environments": @{
                                                                  @"live": @{
                                                                      @"base_url_override": @"/mobile/checkout"
                                                                      }
                                                                  }
                                                              },
                                                          ],
                                                  }
                                          }];
    XCTAssertNotNil(configuration);
    XCTAssertNotNil(configuration.prioritizedCheckoutRecipes);
    XCTAssertEqual([configuration.prioritizedCheckoutRecipes count], (NSUInteger)1);

    PPOTConfigurationCheckoutRecipe *checkoutRecipe = configuration.prioritizedCheckoutRecipes[0];

    PPOTSwitchRequest *switchRequest = [checkoutRequest getAppSwitchRequestForConfigurationRecipe:checkoutRecipe];
    NSURL *expectedURL = [NSURL URLWithString:@"https://www.paypal.com/mobile/checkout?token=TEST_TOKEN_VALUE&otherParam=1"
                          "&x-source=com.braintreepayments.Demo&x-success=com.braintreepayments.Demo.payments://onetouch/v1/success&x-cancel=com.braintreepayments.Demo.payments://onetouch/v1/cancel"];
    XCTAssertEqualObjects(switchRequest.encodedURL, expectedURL);
}

- (void)testURLIsNotChangedWithNoBaseURLOverrideForBillingAgreementRequest {
    NSURL *approvalURL = [NSURL URLWithString:@"https://example.com/webscr/billingAgreement/?token=TEST_TOKEN_VALUE&otherParam=1"];
    PPOTBillingAgreementRequest *billingAgreementRequest = [PPOTRequestFactory billingAgreementRequestWithApprovalURL:approvalURL
                                                                                                             clientID:@"testClientID"
                                                                                                          environment:@"sandbox"
                                                                                                    callbackURLScheme:@"com.braintreepayments.Demo.payments"];
    // If this is nil, then make sure the Hosting App for the test has a Info.plist which contains the callback URL scheme specified in the
    // callbackURLScheme parameter
    XCTAssertNotNil(billingAgreementRequest);
    XCTAssertEqualObjects(approvalURL, billingAgreementRequest.approvalURL);

    PPOTConfiguration *configuration = [PPOTConfiguration configurationWithDictionary:
                                        @{@"os": @"iOS",
                                          @"file_timestamp": @"2014-12-19T16:39:57-08:00",
                                          @"1.0": @{
                                                  @"billing_agreement_recipes_in_decreasing_priority_order": @[
                                                          @{
                                                              @"protocol": @"0",
                                                              @"target": @"browser",
                                                              },
                                                          ],
                                                  }
                                          }];

    PPOTConfigurationBillingAgreementRecipe *billingAgreementRecipe = configuration.prioritizedBillingAgreementRecipes[0];

    PPOTSwitchRequest *switchRequest = [billingAgreementRequest getAppSwitchRequestForConfigurationRecipe:billingAgreementRecipe];
    NSURL *expectedURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                               approvalURL.absoluteString,
                                               @"&x-source=com.braintreepayments.Demo&x-success=com.braintreepayments.Demo.payments://onetouch/v1/success&x-cancel=com.braintreepayments.Demo.payments://onetouch/v1/cancel"]];
    XCTAssertEqualObjects(switchRequest.encodedURL, expectedURL);
}

- (void)testURLIsChangedWithBaseURLOverridePresentForBillingAgreementRequest {
    NSURL *approvalURL = [NSURL URLWithString:@"https://www.sandbox.paypal.com/webscr/billingAgreement/?token=TEST_TOKEN_VALUE&otherParam=1"];
    PPOTBillingAgreementRequest *billingAgreementRequest = [PPOTRequestFactory billingAgreementRequestWithApprovalURL:approvalURL
                                                                                                             clientID:@"testClientID"
                                                                                                          environment:PayPalEnvironmentProduction
                                                                                                    callbackURLScheme:@"com.braintreepayments.Demo.payments"];
    // If this is nil, then make sure the Hosting App for the test has a Info.plist which contains the callback URL scheme specified in the
    // callbackURLScheme parameter
    XCTAssertNotNil(billingAgreementRequest);
    XCTAssertEqualObjects(approvalURL, billingAgreementRequest.approvalURL);

    PPOTConfiguration *configuration = [PPOTConfiguration configurationWithDictionary:
                                        @{@"os": @"iOS",
                                          @"file_timestamp": @"2014-12-19T16:39:57-08:00",
                                          @"1.0": @{
                                                  @"billing_agreement_recipes_in_decreasing_priority_order": @[
                                                          @{
                                                              @"protocol": @"0",
                                                              @"target": @"browser",
                                                              @"environments": @{
                                                                  @"live": @{
                                                                      @"base_url_override": @"/mobile/agreements"
                                                                      }
                                                                  }
                                                              },
                                                          ],
                                                  }
                                          }];
    XCTAssertNotNil(configuration);
    XCTAssertNotNil(configuration.prioritizedBillingAgreementRecipes);
    XCTAssertEqual([configuration.prioritizedBillingAgreementRecipes count], (NSUInteger)1);

    PPOTConfigurationBillingAgreementRecipe *billingAgreementRecipe = configuration.prioritizedBillingAgreementRecipes[0];

    PPOTSwitchRequest *switchRequest = [billingAgreementRequest getAppSwitchRequestForConfigurationRecipe:billingAgreementRecipe];
    NSURL *expectedURL = [NSURL URLWithString:@"https://www.sandbox.paypal.com/mobile/agreements?token=TEST_TOKEN_VALUE&otherParam=1"
                          "&x-source=com.braintreepayments.Demo&x-success=com.braintreepayments.Demo.payments://onetouch/v1/success&x-cancel=com.braintreepayments.Demo.payments://onetouch/v1/cancel"];
    XCTAssertEqualObjects(switchRequest.encodedURL, expectedURL);
}

@end
