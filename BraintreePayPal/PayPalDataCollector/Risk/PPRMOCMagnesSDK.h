#import <Foundation/Foundation.h>
#import "PPRMOCMagnesResult.h"

@interface PPRMOCMagnesSDK : NSObject

typedef enum {
    MAGNES_SOURCE_PAYPAL = 10,
    MAGNES_SOURCE_EBAY = 11,
    MAGNES_SOURCE_BRAINTREE = 12,
    MAGNES_SOURCE_SIMILITY = 17,
    MAGNES_SOURCE_DEFAULT = -1
} MagnesSourceFlow;

typedef enum {
    LIVE = 0,
    SANDBOX = 1,
    STAGE = 2
} MagnesEnvironment;

+ (PPRMOCMagnesSDK *)shared;

- (void)setUpEnvironment:(MagnesEnvironment)env
        withOptionalAppGuid:(NSString *)appGuid
        withOptionalAPNToken:(NSString *)apnToken
  disableRemoteConfiguration:(Boolean)isRemoteConfigDisabled
           disableBeacon:(Boolean)isBeaconDisabled
             forMagnesSource:(MagnesSourceFlow)magnesSource;

- (PPRMOCMagnesSDKResult *)collect;

- (PPRMOCMagnesSDKResult *)collectWithPayPalClientMetadataId:(NSString *)cmid
                                    withAdditionalData:(NSDictionary *)additionalData;

- (PPRMOCMagnesSDKResult *)collectAndSubmit;

- (PPRMOCMagnesSDKResult *)collectAndSubmitWithPayPalClientMetadataId:(NSString *)cmid
                                             withAdditionalData:(NSDictionary *)additionalData;

@end
