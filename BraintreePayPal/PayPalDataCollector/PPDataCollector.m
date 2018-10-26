//
//  PPDataCollector.m
//  PPDataCollector
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import "PPDataCollector_Internal.h"
#import "PPRMOCMagnesSDK.h"
#import "PPRMOCMagnesResult.h"
#if __has_include("PayPalUtils.h")
#import "PPOTDevice.h"
#import "PPOTVersion.h"
#import "PPOTMacros.h"
#import "PPOTURLSession.h"
#else
#import <PayPalUtils/PPOTDevice.h>
#import <PayPalUtils/PPOTVersion.h>
#import <PayPalUtils/PPOTMacros.h>
#import <PayPalUtils/PPOTURLSession.h>
#endif

@implementation PPDataCollector

+ (NSString *)generateClientMetadataID:(NSString *)clientMetadataID disableBeacon:(BOOL)disableBeacon data:(NSDictionary *)data {
    [[PPRMOCMagnesSDK shared] setUpEnvironment:LIVE withOptionalAppGuid:[PPOTDevice appropriateIdentifier] withOptionalAPNToken:nil disableRemoteConfiguration:NO disableBeacon:disableBeacon forMagnesSource:MAGNES_SOURCE_BRAINTREE];

    PPRMOCMagnesSDKResult *result = [[PPRMOCMagnesSDK shared] collectAndSubmitWithPayPalClientMetadataId:[clientMetadataID copy] withAdditionalData:data];
    PPLog(@"ClientMetadataID: %@", [result getPayPalClientMetaDataId]);
    return [result getPayPalClientMetaDataId];
}

+ (NSString *)generateClientMetadataIDWithoutBeacon:(NSString *)clientMetadataID data:(NSDictionary *)data {
    return [PPDataCollector generateClientMetadataID:clientMetadataID disableBeacon:YES data:data];
}

+ (NSString *)generateClientMetadataID {
    return [PPDataCollector generateClientMetadataID:nil disableBeacon:NO data:nil];
}

+ (nonnull NSString *)clientMetadataID:(nullable NSString *)pairingID {
    return [PPDataCollector generateClientMetadataID:pairingID disableBeacon:NO data:nil];
}

+ (nonnull NSString *)clientMetadataID {
    return [self generateClientMetadataID];
}

+ (nonnull NSString *)collectPayPalDeviceData {
    NSMutableDictionary *dataDictionary = [NSMutableDictionary new];
    NSString *payPalClientMetadataId = [PPDataCollector generateClientMetadataID];
    if (payPalClientMetadataId) {
        dataDictionary[@"correlation_id"] = payPalClientMetadataId;
    }
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&error];
    if (!data) {
        NSLog(@"ERROR: Failed to create deviceData string, error = %@", error);
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
