#if __has_include(<Braintree/BraintreeDataCollector.h>)
#import <Braintree/BraintreeCore.h>
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
@property (nonatomic, readonly, assign) BOOL isKountEnabled DEPRECATED_MSG_ATTRIBUTE("Kount Custom support will be removed in the next major version. Use `PPDataCollector.collectPayPalDeviceData()`.");

/**
 Returns the Kount merchant id set in the Gateway
*/
@property (nonatomic, readonly, assign) NSString *kountMerchantID DEPRECATED_MSG_ATTRIBUTE("Kount Custom support will be removed in the next major version. Use `PPDataCollector.collectPayPalDeviceData()`.");

@end
