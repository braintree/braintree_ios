#import <BraintreeCore/BTConfiguration.h>

/**
 BTConfiguration category for UnionPay
 */
@interface BTConfiguration (UnionPay)

/**
 Indicates whether UnionPay is enabled for the merchant account.
*/
@property (nonatomic, readonly, assign) BOOL isUnionPayEnabled;

@end
