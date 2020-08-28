#import <BraintreeCore/BraintreeCore.h>

/**
 BTConfiguration category for DataCollector
 */
@interface BTConfiguration (DataCollector)

/**
 Indicates whether Kount is enabled for the merchant account.
*/
@property (nonatomic, readonly, assign) BOOL isKountEnabled;

/**
 Returns the Kount merchant id set in the Gateway
*/
@property (nonatomic, readonly, assign) NSString *kountMerchantId;

@end
