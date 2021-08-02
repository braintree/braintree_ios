//
//  MagnesCryptoUtil.h
//  PPRiskMagnes
//
//  Created by Zhou, James on 5/10/18.
//  Copyright © 2018 PayPal Risk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MagnesCryptoUtil : NSObject

+ (NSString *)getDCIdWithAppGuid:(NSString *)appGuid
                   withTimestamp:(NSString *)timestamp;

+ (NSString *)getMGIdWithAppGuid:(NSString *)appGuid
                   withTimeStamp:(NSString *)timestampN
                   withPairingId:(NSString *)pairingId
                     withMGIDKey:(NSString *)mgIdKey;

@end
