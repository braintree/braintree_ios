#import "PPDataCollector_Internal.h"
#import <PPRiskMagnes/PPRiskMagnes-Swift.h>
#import <BraintreeCore/BTKeychain.h>

@implementation PPDataCollector

+ (MagnesResult *)generateMagnesResultWithClientMetadataID:(NSString *)clientMetadataID disableBeacon:(BOOL)disableBeacon data:(NSDictionary *)data {
    // TODO: The doc comment for this method is incorrect. The build setting CLANG_WARN_DOCUMENTATION_COMMENTS was temporarily disabled for BraintreePaymentFlow, PayPalOneTouch, and PayPalDataCollector
    [[MagnesSDK shared] setUpWithSetEnviroment:EnvironmentLIVE
                            setOptionalAppGuid:[self appropriateIdentifier]
                           setOptionalAPNToken:@""
                    disableRemoteConfiguration:NO
                                 disableBeacon:disableBeacon
                                  magnesSource:MagnesSourceBRAINTREE
                                         error:nil];

    return [[MagnesSDK shared] collectAndSubmitWithPayPalClientMetadataId:[clientMetadataID copy] withAdditionalData:data error:nil];
}

+ (NSString *)generateClientMetadataID:(NSString *)clientMetadataID disableBeacon:(BOOL)disableBeacon data:(NSDictionary *)data {
    MagnesResult *result = [PPDataCollector generateMagnesResultWithClientMetadataID:clientMetadataID
                                                                       disableBeacon:disableBeacon
                                                                                data:data];

    return [result getPayPalClientMetaDataId];
}

+ (NSString *)generateClientMetadataIDWithoutBeacon:(NSString *)clientMetadataID data:(NSDictionary *)data {
    return [PPDataCollector generateClientMetadataID:clientMetadataID
                                       disableBeacon:YES
                                                data:data];
}

+ (NSString *)generateClientMetadataID {
    return [PPDataCollector generateClientMetadataID:nil
                                       disableBeacon:NO
                                                data:nil];
}

+ (nonnull NSString *)clientMetadataID:(nullable NSString *)pairingID {
    return [PPDataCollector generateClientMetadataID:pairingID
                                       disableBeacon:NO
                                                data:nil];
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
    return [PPDataCollector generateMagnesResultWithClientMetadataID:clientMetadataID
                                                       disableBeacon:NO
                                                                data:nil];
}

+ (NSString *)appropriateIdentifier {
    NSString * const keychainDeviceIdentifier = @"PayPal_MPL_DeviceGUID";
    // see if we already have one
    NSString *appropriateId = [[NSString alloc] initWithData:[BTKeychain dataForKey:keychainDeviceIdentifier]
                                                    encoding:NSUTF8StringEncoding];
    // if not generate a new one and save
    if (!appropriateId.length) {
        appropriateId = [NSUUID UUID].UUIDString;
        [BTKeychain setData:[appropriateId dataUsingEncoding:NSUTF8StringEncoding] forKey:keychainDeviceIdentifier];
    }
    return appropriateId;
}

@end
