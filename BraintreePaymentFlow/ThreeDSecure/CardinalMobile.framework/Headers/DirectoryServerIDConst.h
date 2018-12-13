//
//  DirectoryServerID.h
//  CardinalMobile
//
//  Copyright © 2018 CardinalCommerce. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * CCADirectoryServerID enum defines Directory Servers Supported by the SDK.
 */
typedef enum {
    CCADirectoryServerIDEMVCo1,
    CCADirectoryServerIDEMVCo2,
    CCADirectoryServerIDAmexStaging,
    CCADirectoryServerIDVisa,
    CCADirectoryServerIDMasterCard
} CCADirectoryServerID;

@interface DirectoryServerIDConst : NSObject

extern NSString *DSID_EMVCO1;
extern NSString *DSID_EMVCO2;
extern NSString *DSID_AMEX_STAGING;
extern NSString *DSID_VISA;
extern NSString *DSID_MASTER_CARD;

+ (const NSString *)enumToString:(CCADirectoryServerID)dsIDEnum;

@end
