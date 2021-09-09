#import <Foundation/Foundation.h>
@class BTAPIClient;

NS_ASSUME_NONNULL_BEGIN

/**
 Braintree's advanced fraud protection solution
*/
@interface BTDataCollector : NSObject

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

#pragma mark - Direct Integrations

/**
 Set your fraud merchant id.

 @note If you do not call this method, a generic Braintree value will be used.

 @param fraudMerchantID The fraudMerchantID you have established with your Braintree account manager.
*/
- (void)setFraudMerchantID:(NSString *)fraudMerchantID;

@end

NS_ASSUME_NONNULL_END
