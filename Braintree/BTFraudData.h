#import <Foundation/Foundation.h>
#import "BTAPIClient.h"
#import "BTNullability.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTFraudData : NSObject

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

- (BT_NULLABLE NSString *)collectDeviceData;

- (void)collectDeviceDataWithCompletion:(void (^)(NSString __BT_NULLABLE *deviceData, NSError __BT_NULLABLE *error))completionBlock;

- (BT_NULLABLE NSString *)collectFraudDeviceDataWithMerchantID:(NSString *)merchantId collectorUrl:(NSString *)collectorUrl;

- (void)collectFraudDeviceDataWithMerchantID:(NSString *)merchantId collectorUrl:(NSString *)collectorUrl completion:(void (^)(NSString __BT_NULLABLE *deviceData, NSError __BT_NULLABLE *error))completionBlock;

@end

BT_ASSUME_NONNULL_END
