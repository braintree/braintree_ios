//
//  PPDataCollectorTest.m
//  PayPalOneTouch
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PPDataCollector_Internal.h"
#import "PPRMOCMagnesResult.h"

@interface PPDataCollectorTest : XCTestCase

@end

@implementation PPDataCollectorTest

- (void)testDeviceData_containsCorrelationId {
    // Collect client metadata ID with a canned pairing ID to guarantee that the pairing ID
    // hasn't already been configured by another test. Also, we can then assert the value of
    // the correlation_id in the JSON object because we know the client metadata ID will be
    // equal to the pairing ID.
    [PPDataCollector clientMetadataID:@"expected_correlation_id"];
    NSString *deviceData = [PPDataCollector collectPayPalDeviceData];
    NSData *data = [deviceData dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
    NSString *cmid = [dictionary objectForKey:@"correlation_id"];

    XCTAssertEqualObjects(cmid, @"expected_correlation_id");
}

- (void)testClientMetadata_isNotJSON {
    NSString *cmid = [PPDataCollector generateClientMetadataID];
    NSData *cmidJSONData = [cmid dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:cmidJSONData options:0 error:&error];

    XCTAssertNil(json);
    XCTAssertNotNil(error);
}

- (void)testClientMetadataValue_whenUsingPairingID_isSameWhenSubsequentCallsDoNotSpecifyPairingID {
    NSString *pairingID = @"random pairing id";
    XCTAssertEqualObjects(pairingID, [PPDataCollector clientMetadataID:pairingID]);
    XCTAssertEqualObjects(pairingID, [PPDataCollector generateClientMetadataID]);
    XCTAssertEqualObjects(pairingID, [PPDataCollector clientMetadataID:nil]);
}

- (void)testClientMetadataValue_isRegeneratedOnNonNullPairingID {
    NSString *cmid = [PPDataCollector generateClientMetadataID];
    NSString *cmid2 = [PPDataCollector clientMetadataID:@"some pairing id"];
    XCTAssertNotEqualObjects(cmid, cmid2);
}

- (void)testCollectPayPalDeviceInfoWithClientMetadataID {
    NSString *pairingID = @"pairing id for device info";
    PPRMOCMagnesSDKResult *result = [PPDataCollector collectPayPalDeviceInfoWithClientMetadataID:pairingID];
    XCTAssertNotNil(result);
    NSDictionary *payloadDict = [result getDeviceInfo];
    XCTAssertNotNil(payloadDict);

    NSData *data = [NSJSONSerialization dataWithJSONObject:payloadDict options:0 error:nil];
    XCTAssertNotNil(data);
    NSString *deviceInfo = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    XCTAssertTrue([deviceInfo containsString:pairingID]);
}

@end
