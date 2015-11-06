#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BTDataCollectorEnvironment) {
    BTDataCollectorEnvironmentDevelopment,
    BTDataCollectorEnvironmentQA,
    BTDataCollectorEnvironmentSandbox,
    BTDataCollectorEnvironmentProduction
};

@protocol BTDataCollectorDelegate;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const BTDataCollectorKountErrorDomain;

/// BTDataCollector - Braintree's advanced fraud protection solution
@interface BTDataCollector : NSObject

/// Set a BTDataCollectorDelegate to receive notifications about collector events.
///
/// @see BTDataCollectorDelegate protocol declaration
@property (nonatomic, weak) id<BTDataCollectorDelegate> delegate;

/// Initializes a `BTDataCollector` instance for an environment.
///
/// @param environment The desired environment to target. This setting will determine which
/// default collectorURL is used when collecting fraud data from the device.
- (instancetype)initWithEnvironment:(BTDataCollectorEnvironment)environment;

/// Generates a new PayPal fraud ID if PayPal is integrated; otherwise returns `nil`.
///
/// @return A PayPal fraud ID
+ (nullable NSString *)payPalClientMetadataId;

/// Collects device data for Kount.
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

/// Collects device data for PayPal.
///
/// This should be used when the user is paying with PayPal only.
///
/// @return a deviceData string that should be passed into server-side calls, such as `Transaction.sale`,
///         for PayPal transactions. This JSON serialized string contains a PayPal fraud ID.
- (NSString *)collectPayPalClientMetadataId;

/// Collects device data using Kount and PayPal.
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
///         This JSON serialized string contains the merchant ID, session ID, and
///         the PayPal fraud ID (if PayPal is available).
- (NSString *)collectFraudData;

#pragma mark Direct Integrations

/// Set your fraud merchant id.
///
/// @note If you do not call this method, a generic Braintree value will be used.
///
/// @param fraudMerchantId The fraudMerchantId you have established with your Braintree account manager.
- (void)setFraudMerchantId:(NSString *)fraudMerchantId;

/// Set the URL that the Device Collector will use.
///
/// @note If you do not call this method, a generic Braintree value will be used.
///
/// @param url Full URL to device collector 302-redirect page
- (void)setCollectorUrl:(NSString *)url;

@end

/// Provides status updates from a BTDataCollector instance.
/// At this time, updates will only be sent for card fraud data (from Kount).
@protocol BTDataCollectorDelegate <NSObject>

/// The collector finished successfully.
///
/// Use this delegate method if, due to fraud, you want to wait
/// until collection completes before performing a transaction.
///
/// This method is required because there's no reason to implement BTDataCollectorDelegate without this method.
- (void)dataCollectorDidComplete:(BTDataCollector *)dataCollector;

@optional

/// The collector has started.
- (void)dataCollectorDidStart:(BTDataCollector *)dataCollector;

/// An error occurred.
///
/// @param error Triggering error. If the error domain is BTDataCollectorKountErrorDomain, then the
///              errorCode is a Kount error code. See error.userInfo[NSLocalizedFailureReasonErrorKey]
///              for the cause of the failure.
- (void)dataCollector:(BTDataCollector *)dataCollector didFailWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
