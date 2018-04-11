#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

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
