//
//  PPDataCollector.m
//  PPDataCollector
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import "PPDataCollector_Internal.h"
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

+ (MagnesResult *)generateMagnesResultWithClientMetadataID:(NSString *)clientMetadataID disableBeacon:(BOOL)disableBeacon data:(NSDictionary *)data {
    // TODO: The doc comment for this method is incorrect. The build setting CLANG_WARN_DOCUMENTATION_COMMENTS was temporarily disabled for BraintreePaymentFlow, PayPalOneTouch, and PayPalDataCollector
    [[MagnesSDK shared] setUpWithSetEnviroment:EnvironmentLIVE
                            setOptionalAppGuid:[PPOTDevice appropriateIdentifier]
                           setOptionalAPNToken:@""
                    disableRemoteConfiguration:NO
                                 disableBeacon:disableBeacon
                                  magnesSource:MagnesSourceBRAINTREE
                                         error:nil];

    return [[MagnesSDK shared] collectAndSubmitWithPayPalClientMetadataId:[clientMetadataID copy] withAdditionalData:data error:nil];
}

+ (NSString *)generateClientMetadataID:(NSString *)clientMetadataID disableBeacon:(BOOL)disableBeacon data:(NSDictionary *)data {
    MagnesResult *result = [PPDataCollector generateMagnesResultWithClientMetadataID:clientMetadataID disableBeacon:disableBeacon data:data];

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

+ (MagnesResult *)collectPayPalDeviceInfoWithClientMetadataID:(nullable NSString *)clientMetadataID {
    return [PPDataCollector generateMagnesResultWithClientMetadataID:clientMetadataID disableBeacon:NO data:nil];
}

@end
