//
//  PPOTConfigurationTest.m
//  PayPalOneTouch
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PPOTConfiguration.h"

@interface PPOTConfigurationTest : XCTestCase

@end

@implementation PPOTConfigurationTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBadOS {
    PPOTConfiguration *configuration = [PPOTConfiguration configurationWithDictionary:
                                        @{@"os": @"Android",
                                          @"file_timestamp": @"2014-12-19T16:39:57-08:00",
                                          @"1.0": @{
                                                  }
                                          }];
    XCTAssertNil(configuration);
}

- (void)testBadFileFormatVersion {
    PPOTConfiguration *configuration = [PPOTConfiguration configurationWithDictionary:
                                        @{@"os": @"iOS",
                                          @"file_timestamp": @"2014-12-19T16:39:57-08:00",
                                          @"2.0": @{
                                                  @"oauth2_recipes_in_decreasing_priority_order": @[
                                                          ],
                                                  }
                                          }];
    XCTAssertNil(configuration);
}

- (void)testEmptyOAuthRecipes {
    PPOTConfiguration *configuration = [PPOTConfiguration configurationWithDictionary:
                                        @{@"os": @"iOS",
                                          @"file_timestamp": @"2014-12-19T16:39:57-08:00",
                                          @"1.0": @{
                                                  @"oauth2_recipes_in_decreasing_priority_order": @[
                                                          ],
                                                  }
                                          }];
    XCTAssertNotNil(configuration);
    XCTAssertNotNil(configuration.prioritizedOAuthRecipes);
    XCTAssert([configuration.prioritizedOAuthRecipes count] == 0);
}

- (void)testGoodOAuthRecipes {
    PPOTConfiguration *configuration = [PPOTConfiguration configurationWithDictionary:
                                        @{@"os": @"iOS",
                                          @"file_timestamp": @"2014-12-19T16:39:57-08:00",
                                          @"1.0": @{
                                                  @"oauth2_recipes_in_decreasing_priority_order": @[
                                                          @{
                                                              @"protocol": @"2",
                                                              @"target": @"wallet",
                                                              @"scope": @[@"*"],
                                                              @"scheme": @"com.paypal.ppclient.touch.v2",
                                                              @"applications": @[@"com.paypal.ppclient", @"com.yourcompany.ppclient"],
                                                              },
                                                          @{
                                                              @"protocol": @"0",
                                                              @"target": @"browser",
                                                              @"scope": @[@"*"],
                                                              @"url": @"https://checkout.paypal.com/login",
                                                              },
                                                          ],
                                                  }
                                          }];
    XCTAssertNotNil(configuration);
    XCTAssertNotNil(configuration.prioritizedOAuthRecipes);
    XCTAssert([configuration.prioritizedOAuthRecipes count] == 2);
    XCTAssert([configuration.prioritizedOAuthRecipes[0] isKindOfClass:[PPOTConfigurationOAuthRecipe class]]);
    XCTAssert([configuration.prioritizedOAuthRecipes[1] isKindOfClass:[PPOTConfigurationOAuthRecipe class]]);
}

- (void)testBadOAuthRecipes {
    // Bad "target"
    PPOTConfiguration *configuration1 = [PPOTConfiguration configurationWithDictionary:
                                         @{@"os": @"iOS",
                                           @"file_timestamp": @"2014-12-19T16:39:57-08:00",
                                           @"1.0": @{
                                                   @"oauth2_recipes_in_decreasing_priority_order": @[
                                                           @{
                                                               @"target": @"UNKNOWN TARGET",
                                                               @"scope": @[@"*"],
                                                               @"scheme": @"com.paypal.ppclient.touch.v2",
                                                               @"applications": @[@"com.paypal.ppclient", @"com.yourcompany.ppclient"],
                                                               },
                                                           @{
                                                               @"target": @"browser",
                                                               @"scope": @[@"*"],
                                                               @"url": @"https://checkout.paypal.com/login",
                                                               },
                                                           ],
                                                   }
                                           }];
    XCTAssertNil(configuration1);

    // Missing "scope"
    PPOTConfiguration *configuration2 = [PPOTConfiguration configurationWithDictionary:
                                         @{@"os": @"iOS",
                                           @"file_timestamp": @"2014-12-19T16:39:57-08:00",
                                           @"1.0": @{
                                                   @"oauth2_recipes_in_decreasing_priority_order": @[
                                                           @{
                                                               @"target": @"wallet",
                                                               @"scheme": @"com.paypal.ppclient.touch.v2",
                                                               @"applications": @[@"com.paypal.ppclient", @"com.yourcompany.ppclient"],
                                                               },
                                                           @{
                                                               @"target": @"browser",
                                                               @"scope": @[@"*"],
                                                               @"url": @"https://checkout.paypal.com/login",
                                                               },
                                                           ],
                                                   }
                                           }];
    XCTAssertNil(configuration2);

    // Missing "url"
    PPOTConfiguration *configuration3 = [PPOTConfiguration configurationWithDictionary:
                                         @{@"os": @"iOS",
                                           @"file_timestamp": @"2014-12-19T16:39:57-08:00",
                                           @"1.0": @{
                                                   @"oauth2_recipes_in_decreasing_priority_order": @[
                                                           @{
                                                               @"target": @"wallet",
                                                               @"scope": @[@"*"],
                                                               @"scheme": @"com.paypal.ppclient.touch.v2",
                                                               @"applications": @[@"com.paypal.ppclient", @"com.yourcompany.ppclient"],
                                                               },
                                                           @{
                                                               @"target": @"browser",
                                                               @"scope": @[@"*"],
                                                               },
                                                           ],
                                                   }
                                           }];
    XCTAssertNil(configuration3);
}

@end
