#if __has_include(<Braintree/BraintreeUnionPay.h>)
#import <Braintree/BraintreeCore-Swift.h>
#else
#import <BraintreeCore/BraintreeCore-Swift.h>
#endif

/**
 BTConfiguration category for UnionPay
 */
@interface BTConfiguration (UnionPay)

/**
 Indicates whether UnionPay is enabled for the merchant account.
*/
@property (nonatomic, readonly, assign) BOOL isUnionPayEnabled;

@end
