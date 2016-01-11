//
//  PPDataCollector.h
//  PayPalDataCollector
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPDataCollector : NSObject

/// Returns a client metadata ID.
///
/// @param pairingID a pairing ID to associate with this clientMetadataID must be 10-32 chars long or null
/// @return a client metadata ID to send as a header
+ (nonnull NSString *)clientMetadataID:(nullable NSString *)pairingID;

/// Returns a client metadata ID.
///
/// @return a client metadata ID to send as a header
+ (nonnull NSString *)clientMetadataID;

@end
