#import <Foundation/Foundation.h>
#import "BTConfiguration.h"
#import "BTNullability.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTFraudData : NSObject

- (instancetype)initWithConfiguration:(BTConfiguration *)configuration;

- (BT_NULLABLE NSString *)collectDeviceData;

- (void)collectDeviceDataWithCompletion:(void (^)(NSString __BT_NULLABLE *deviceData, NSError __BT_NULLABLE *error))completionBlock;

- (BT_NULLABLE NSString *)collectFraudDeviceDataWithMerchantID:(NSString *)merchantId collectorUrl:(NSString *)collectorUrl;

- (void)collectFraudDeviceDataWithMerchantID:(NSString *)merchantId collectorUrl:(NSString *)collectorUrl completion:(void (^)(NSString __BT_NULLABLE *deviceData, NSError __BT_NULLABLE *error))completionBlock;

@end

BT_ASSUME_NONNULL_END
