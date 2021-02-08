#import <Foundation/Foundation.h>
@class BTAPIClient;

@protocol BTDataCollectorDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 Domain for Kount errors.
 */
extern NSString * const BTDataCollectorKountErrorDomain;

/**
 Braintree's advanced fraud protection solution
*/
@interface BTDataCollector : NSObject

/**
 Set a BTDataCollectorDelegate to receive notifications about collector events.
 @see BTDataCollectorDelegate protocol declaration
*/
@property (nonatomic, weak) id<BTDataCollectorDelegate> delegate;

/**
 Initializes a `BTDataCollector` instance with a BTAPIClient.

 @param apiClient The API client which can retrieve remote configuration for the data collector.
*/
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

/**
 Collects device data based on your merchant configuration.

 We recommend that you call this method as early as possible, e.g. at app launch. If that's too early,
 calling it when the customer initiates checkout is also fine.

 Use the return value on your server, e.g. with `Transaction.sale`.

 @param completion A completion block that returns a deviceData string that should be passed into server-side calls, such as `Transaction.sale`.
*/
- (void)collectDeviceData:(void (^)(NSString *deviceData))completion;

/**
 Collects device data for Kount.

 This should be used when the user is paying with a card.

 For lifecycle events such as a completion callback, use BTDataCollectorDelegate. Although you do not need
 to wait for the completion callback before performing the transaction, the data will be most effective if you do.
 Normal response time is less than 1 second, and it should never take more than 10 seconds.

 We recommend that you call this method as early as possible, e.g. at app launch. If that's too early,
 calling it e.g. when the customer initiates checkout should also be fine.

 @param completion A completion block callback that returns a deviceData string that should be passed in to server-side calls, such as `Transaction.sale` This JSON serialized string contains the merchant ID and session ID.
*/
- (void)collectCardFraudData:(void (^)(NSString *deviceData))completion;

#pragma mark - Direct Integrations

/**
 Set your fraud merchant id.

 @note If you do not call this method, a generic Braintree value will be used.

 @param fraudMerchantID The fraudMerchantID you have established with your Braintree account manager.
*/
- (void)setFraudMerchantID:(NSString *)fraudMerchantID;

@end

/**
 Provides status updates from a BTDataCollector instance. At this time, updates will only be sent for card fraud data (from Kount).
*/
@protocol BTDataCollectorDelegate <NSObject>

/**
 The collector finished successfully.

 Use this delegate method if, due to fraud, you want to wait
 until collection completes before performing a transaction.

 This method is required because there's no reason to implement BTDataCollectorDelegate without this method.
*/
- (void)dataCollectorDidComplete:(BTDataCollector *)dataCollector;

@optional

/**
 The collector has started.
*/
- (void)dataCollectorDidStart:(BTDataCollector *)dataCollector;

/**
 An error occurred.

 @param error Triggering error. If the error domain is BTDataCollectorKountErrorDomain, then the
              errorCode is a Kount error code. See error.userInfo[NSLocalizedFailureReasonErrorKey]
              for the cause of the failure.
*/
- (void)dataCollector:(BTDataCollector *)dataCollector didFailWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
