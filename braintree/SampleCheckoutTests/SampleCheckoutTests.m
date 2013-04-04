//
//  SampleCheckoutTests.m
//  SampleCheckoutTests
//
//  Created by kortina on 3/28/13.
//  Copyright (c) 2013 Braintree. All rights reserved.
//

#import "SampleCheckoutTests.h"
#import <VenmoTouch/VenmoTouch.h>

@implementation SampleCheckoutTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSLog(@"BT_SANDBOX_MERCHANT_ID: %@", BT_SANDBOX_MERCHANT_ID);
    NSLog(@"BT_SANDBOX_PUBLIC_ENCRYPTION_KEY: %@", BT_SANDBOX_PUBLIC_ENCRYPTION_KEY);
    NSLog(@"BT_ENVIRONMENT: %@", BT_ENVIRONMENT);
    
    STAssertEqualObjects(BT_ENVIRONMENT, @"sandbox", @"Environment should be sandbox");
    STAssertFalse([BT_SANDBOX_MERCHANT_ID isEqualToString:@"your_sandbox_merchant_id"], @"Merchant id should be set to something other than 'your_sandbox_merchant_id'");
    STAssertFalse([BT_PRODUCTION_MERCHANT_ID isEqualToString:@"your_production_merchant_id"], @"Merchant id should be set to something other than 'your_production_merchant_id'");

}

@end
