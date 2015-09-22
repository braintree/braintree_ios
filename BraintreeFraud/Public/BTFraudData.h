#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BTFraudDataEnvironment) {
    BTFraudDataEnvironmentDevelopment,
    BTFraudDataEnvironmentQA,
    BTFraudDataEnvironmentSandbox,
    BTFraudDataEnvironmentProduction
};

NS_ASSUME_NONNULL_BEGIN

@interface BTFraudData : NSObject

- (instancetype)initWithEnvironment:(BTFraudDataEnvironment)environment;

/// Generates a new clientMetadataID if using PayPalOneTouchCore - otherwise returns nil
+ (NSString *)payPalFraudID;

/// Collects device data using Kount, uses the default merchant ID and collector URL.
- (void)collectCardFraudData:(nullable void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock;

/// Collects device data using Kount, using your own merchant ID and collector URL
- (void)collectCardFraudDataWithMerchantID:(NSString *)merchantID collectorURL:(NSString *)collectorURL completion:(void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock;

/// Collects ALL device data using Kount and PayPal, uses the default merchant ID and collector URL for Kount.
- (void)collectFraudData:(nullable void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock;

/// Collects ALL device data using Kount and PayPal, using your own merchant ID and collector URL for Kount.
- (void)collectFraudDataWithMerchantID:(NSString *)merchantID collectorURL:(NSString *)collectorURL completion:(void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
