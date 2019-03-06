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
    CCADirectoryServerIDVisaSDK,
    CCADirectoryServerIDVisa01,
    CCADirectoryServerIDVisa02,
    CCADirectoryServerIDVisa03,
    CCADirectoryServerIDMasterCard
} CCADirectoryServerID;

@interface DirectoryServerIDConst : NSObject

extern NSString *DSID_EMVCO1;
extern NSString *DSID_EMVCO2;
extern NSString *DSID_AMEX_STAGING;
extern NSString *DSID_VISA;
extern NSString *DSID_VISA_01;
extern NSString *DSID_VISA_02;
extern NSString *DSID_VISA_03;
extern NSString *DSID_VISA_SDK;
extern NSString *DSID_MASTER_CARD;

+ (NSString *)enumToString:(const CCADirectoryServerID)dsIDEnum;

@end
