//
//  BTPaymentTests.m
//  BTPaymentTests
//
//  Created by kortina on 3/28/13.
//  Copyright (c) 2013 Braintree. All rights reserved.
//

#import "BTPaymentTests.h"
#import "BTPaymentCardUtils.h"

@implementation BTPaymentTests

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

- (void)testFormatNumber
{
    
    NSString *cardNumberForViewing = @"4111  1111  1111  1111";
    NSString *cardNumberForComputing = @"4111111111111111";
    
    STAssertTrue([cardNumberForViewing isEqualToString:[BTPaymentCardUtils formatNumberForViewing:cardNumberForComputing]], @"formatNumberForViewing correctly spaces Visa card number");
}

@end
