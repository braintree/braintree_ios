#if SWIFT_PACKAGE
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
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
