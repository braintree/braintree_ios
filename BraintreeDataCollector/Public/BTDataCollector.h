#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BTDataCollectorEnvironment) {
    BTDataCollectorEnvironmentDevelopment,
    BTDataCollectorEnvironmentQA,
    BTDataCollectorEnvironmentSandbox,
    BTDataCollectorEnvironmentProduction
};

NS_ASSUME_NONNULL_BEGIN

@interface BTDataCollector : NSObject

/// Initializes a `BTDataCollector` instance for an environment.
///
/// @param environment The desired environment to target. This setting will determine which
/// default collectorURL is used when collecting fraud data from the device.
- (instancetype)initWithEnvironment:(BTDataCollectorEnvironment)environment;


/// Generates a new PayPal fraud ID (i.e. PayPalOneTouchCore `clientMetadataID`) if PayPal is integrated, otherwise returns `nil`
///
/// @return A PayPal fraud ID
+ (nullable NSString *)payPalFraudID;


/// Collects device data using the default merchant ID and collector URL.
///
/// This should be used when the user is paying with a card.
///
/// @param completionBlock A callback block that gets invoked when fraud data collection has finished. It
///                        returns fraud data to send to your server when successful, or an error when it fails.
- (void)collectCardFraudData:(nullable void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock;


/// Collects device data using your own merchant ID and a custom collector URL.
///
/// This should be used when the user is paying with a card.
///
/// @param completionBlock A callback block that gets invoked when fraud data collection has finished. It
///                        returns fraud data to send to your server when successful, or an error when it fails.
- (void)collectCardFraudDataWithMerchantID:(NSString *)merchantID
                              collectorURL:(NSString *)collectorURL
                                completion:(void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock;


/// Collects device data using Kount and PayPal. Uses the default merchant ID and collector URL for Kount.
///
/// This method collects device data using both Kount and PayPal. If you want to collect data for Kount,
/// use `-collectCardFraudData:`. To collect data for PayPal, use `+payPalFraudID`. When possible, you should
/// avoid using Kount when processing a PayPal transaction because it expends bandwidth and storage unnecessarily.
///
/// @param completionBlock An optional callback block that gets invoked when fraud data collection has finished.
///                        When successful, you should send the deviceData identifier to your server.
///                        On failure, you may receive an error.
///
/// @return a deviceData string that should be passed into server-side calls, such as Transaction.create.
///         If data is already being collected, this method returns nil.
- (NSString *)collectFraudData:(void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock;


/// Collects device data using Kount and PayPal. Uses your own merchant ID and collector URL for Kount.
///
/// This method collects device data using both Kount and PayPal. If you want to collect data for Kount,
/// use `-collectCardFraudData:`. To collect data for PayPal, use `+payPalFraudID`. When possible, you should
/// avoid using Kount when processing a PayPal transaction because it expends bandwidth and storage unnecessarily.
///
/// @param completionBlock A callback block that gets invoked when fraud data collection has finished.
///                        When successful, you should send the deviceData identifier to your server.
///                        On failure, you may receive an error.
///
/// @return a deviceData string that should be passed into server-side calls, such as Transaction.create.
///         If data is already being collected, this method returns nil.
- (NSString *)collectFraudDataWithMerchantID:(NSString *)merchantID
                                collectorURL:(NSString *)collectorURL
                                  completion:(void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
