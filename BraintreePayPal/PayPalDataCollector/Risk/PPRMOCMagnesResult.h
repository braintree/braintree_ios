#import <Foundation/Foundation.h>

@interface PPRMOCMagnesSDKResult : NSObject

- (id)initWithDeviceInfo:(NSDictionary *)deviceInfo
             withPayPalClientMetaDataId:(NSString *)cmid;

- (NSDictionary *)getDeviceInfo;

- (NSString *)getPayPalClientMetaDataId;

@end
