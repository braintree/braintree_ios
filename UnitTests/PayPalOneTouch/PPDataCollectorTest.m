//
//  PPDataCollectorTest.m
//  PayPalOneTouch
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PayPalDataCollector.h"

@interface PPDataCollectorTest : XCTestCase

@end

@implementation PPDataCollectorTest

- (void)testDeviceDataContainsCorrelationIdKey {
    NSString *deviceData = [PPDataCollector collectPayPalDeviceData];
    NSData *data = [deviceData dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
    NSString *cmid = [dictionary objectForKey:@"correlation_id"];
    XCTAssert(cmid.length >= 32);
}

- (void)testClientMetadataDoesNotContainCorrelationIdKey {
    NSString *cmid = [PPDataCollector clientMetadataID];
    XCTAssertTrue([cmid rangeOfString:@"correlation_id"].location == NSNotFound);
    XCTAssert(cmid.length >= 12);
}

@end
