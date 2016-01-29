//
//  PPDataCollector.m
//  PPDataCollector
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import "PPDataCollector.h"
#import "PPRCClientMetadataIDProvider.h"

#import "PPOTDevice.h"
#import "PPOTVersion.h"
#import "PPOTMacros.h"
#import "PPOTURLSession.h"

@implementation PPDataCollector

+ (PPRCClientMetadataIDProvider *)clientMetadataIDProvider {
    static dispatch_once_t onceToken;
    static PPRCClientMetadataIDProvider *clientMetadataIDProvider;

    dispatch_once(&onceToken, ^{
        // Keep this as a long lived session
        PPOTURLSession *session = [PPOTURLSession session];

        PPRCClientMetadataIDProviderNetworkAdapterBlock adapterBlock = ^(NSURLRequest *request, PPRCClientMetadataIDProviderNetworkResponseBlock completionBlock) {
            [session sendRequest:request completionBlock:^(NSData* responseData, NSHTTPURLResponse *response, __attribute__((unused)) NSError *error) {
                completionBlock(response, responseData);
            }];
        };

        clientMetadataIDProvider = [[PPRCClientMetadataIDProvider alloc] initWithAppGuid:[PPOTDevice appropriateIdentifier]
                                                                        sourceAppVersion:PayPalOTVersion()
                                                                     networkAdapterBlock:adapterBlock];
    });

    return clientMetadataIDProvider;
}

+ (nonnull NSString *)clientMetadataID:(nullable NSString *)pairingID {
    NSString *clientMetadataID = [[PPDataCollector clientMetadataIDProvider] clientMetadataID:pairingID];
    PPLog(@"ClientMetadataID: %@", clientMetadataID);
    return clientMetadataID;
}

+ (nonnull NSString *)clientMetadataID {
    return [[PPDataCollector clientMetadataIDProvider] clientMetadataID:nil];
}

+ (nonnull NSString *)collectPayPalDeviceData {
    NSMutableDictionary *dataDictionary = [NSMutableDictionary new];
    NSString *payPalClientMetadataId = [PPDataCollector clientMetadataID];
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
