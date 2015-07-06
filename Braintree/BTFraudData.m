#import "BTFraudData.h"

@implementation BTFraudData

- (instancetype)initWithAPIClient:(nonnull BTAPIClient *)apiClient {
    return [self init];
}

- (nullable NSString *)collectDeviceData {
    // TODO
    return nil;
}

- (void)collectDeviceDataWithCompletion:(nonnull void (^)(NSString * __nullable, NSError * __nullable))completionBlock {
    // TODO
}

- (nullable NSString *)collectFraudDeviceDataWithMerchantID:(nonnull NSString *)merchantId collectorUrl:(nonnull NSString *)collectorUrl {
    // TODO
    return nil;
}

- (void)collectFraudDeviceDataWithMerchantID:(nonnull NSString *)merchantId collectorUrl:(nonnull NSString *)collectorUrl completion:(nonnull void (^)(NSString * __nullable, NSError * __nullable))completionBlock {
    // TODO
}

@end
