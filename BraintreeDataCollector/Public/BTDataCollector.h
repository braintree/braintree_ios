#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BTDataCollectorEnvironment) {
    BTDataCollectorEnvironmentDevelopment,
    BTDataCollectorEnvironmentQA,
    BTDataCollectorEnvironmentSandbox,
    BTDataCollectorEnvironmentProduction
};

NS_ASSUME_NONNULL_BEGIN

/// Provides status updates from a BTDataCollector instance.
/// At this time, updates will only be sent for card fraud data (from Kount).
@protocol BTDataCollectorDelegate <NSObject>
@optional

/// The collector has started.
- (void)onCollectorStart;

/// The collector finished successfully.
- (void)onCollectorSuccess;

/// An error occurred.
///
/// @param errorCode Error code
/// @param error Triggering error if available
- (void)onCollectorError:(int)errorCode
               withError:(NSError *)error;
@end

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
/// For lifecycle events such as a completion callback, use BTDataCollectorDelegate. Although you do not need
/// to wait for the completion callback before performing the transaction, the data will be most effective if you do.
/// Normal response time is less than 1 second, and it should never take more than 10 seconds.
///
/// We recommend that you call this method as early as possible, e.g. at app launch. If that's too early,
/// calling it e.g. when the customer initiates checkout should also be fine.
///
/// @return a deviceData string that should be passed into server-side calls, such as `Transaction.sale`.
///         This JSON serialized string contains the merchant ID and session ID.
- (NSString *)collectCardFraudData;


/// Collects device data using your own merchant ID and a custom collector URL.
///
/// This should be used when the user is paying with a card.
///
/// For lifecycle events such as a completion callback, use BTDataCollectorDelegate. Although you do not need
/// to wait for the completion callback before performing the transaction, the data will be most effective if you do.
/// Normal response time is less than 1 second, and it should never take more than 10 seconds.
///
/// We recommend that you call this method as early as possible, e.g. at app launch. If that's too early,
/// calling it e.g. when the customer initiates checkout should also be fine.
///
/// @return a deviceData string that should be passed into server-side calls, such as `Transaction.sale`.
///         This JSON serialized string contains the merchant ID and session ID.
- (NSString *)collectCardFraudDataWithMerchantID:(NSString *)merchantID
                                    collectorURL:(NSString *)collectorURL;


/// Collects device data using Kount and PayPal. Uses the default merchant ID and collector URL for Kount.
///
/// This method collects device data using both Kount and PayPal. If you want to collect data for Kount,
/// use `-collectCardFraudData`. To collect data for PayPal, use `+payPalFraudID`.
///
/// For lifecycle events such as a completion callback, use BTDataCollectorDelegate. Although you do not need
/// to wait for the completion callback before performing the transaction, the data will be most effective if you do.
/// Normal response time is less than 1 second, and it should never take more than 10 seconds.
///
/// We recommend that you call this method as early as possible, e.g. at app launch. If that's too early,
/// calling it e.g. when the customer initiates checkout should also be fine.
///
/// Store the return value as deviceData to use with debit/credit card transactions on your server,
/// e.g. with `Transaction.sale`.
///
/// @return a deviceData string that should be passed into server-side calls, such as `Transaction.sale`.
///         This JSON serialized string contains the merchant ID, session ID, and the PayPal fraud ID (if PayPal is available).
- (NSString *)collectFraudData;


/// Collects device data using Kount and PayPal. Uses your own merchant ID and collector URL for Kount.
///
/// This method collects device data using both Kount and PayPal. If you want to collect data for Kount,
/// use `-collectCardFraudData:`. To collect data for PayPal, use `+payPalFraudID`.
///
/// For lifecycle events such as a completion callback, use BTDataCollectorDelegate. Although you do not need
/// to wait for the completion callback before performing the transaction, the data will be most effective if you do.
/// Normal response time is less than 1 second, and it should never take more than 10 seconds.
///
/// We recommend that you call this method as early as possible, e.g. at app launch. If that's too early,
/// calling it e.g. when the customer initiates checkout should also be fine.
///
/// Store the return value as deviceData to use with debit/credit card transactions on your server,
/// e.g. with `Transaction.sale`.
///
/// @return a deviceData string that should be passed into server-side calls, such as `Transaction.sale`.
///         If data is already being collected, this method returns nil.
///         If you need to collect device data repeatedly, create a new BTDataCollector instance.
///
/// @return a deviceData string that should be passed into server-side calls, such as `Transaction.sale`.
///         This JSON serialized string contains the merchant ID, session ID, and the PayPal fraud ID (if PayPal is available).
- (NSString *)collectFraudDataWithMerchantID:(NSString *)merchantID
                                collectorURL:(NSString *)collectorURL;

/// @see BTDataCollectorDelegate protocol declaration
@property (nonatomic, weak) id<BTDataCollectorDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
