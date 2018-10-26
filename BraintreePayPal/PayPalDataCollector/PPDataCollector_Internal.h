//
//  PPDataCollector.h
//  PayPalDataCollector
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import "PPDataCollector.h"

@interface PPDataCollector ()

/**
 Generates a client metadata ID using an optional pairing ID and additional options.

 @note This is an internal method for generating raw client metadata IDs, which is not
 the correct format for device data when creating a transaction.

 @param clientMetadataID an ID to associate with this clientMetadataID must be 10-32 chars long or null
 @param disableBeacon a Boolean indicating whether or not to disable the beacon feature.
 @param data additional key/value pairs to associate with the risk data.
 @return a client metadata ID to send as a header
*/
+ (nonnull NSString *)generateClientMetadataID:(nullable NSString *)clientMetadataID disableBeacon:(BOOL)disableBeacon data:(nullable NSDictionary *)data;

/**
 Generates a client metadata ID using an optional pairing ID and additional data. Disables the beacon feature.

 @note This is an internal method for generating raw client metadata IDs, which is not
 the correct format for device data when creating a transaction.

 @param clientMetadataID an ID to associate with this clientMetadataID must be 10-32 chars long or null
 @param data additional key/value pairs to associate with the risk data.
 @return a client metadata ID to send as a header
 */
+ (nonnull NSString *)generateClientMetadataIDWithoutBeacon:(nullable NSString *)clientMetadataID data:(nullable NSDictionary *)data;

/**
 Generates a client metadata ID.

 @note This is an internal method for generating raw client metadata IDs, which is not
 the correct format for device data when creating a transaction.

 @return a client metadata ID to send as a header
*/
+ (nonnull NSString *)generateClientMetadataID;

@end
