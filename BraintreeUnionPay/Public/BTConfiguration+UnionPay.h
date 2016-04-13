#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

@interface BTConfiguration (UnionPay)

/// Indicates whether UnionPay is enabled for the merchant account.
@property (nonatomic, readonly, assign) BOOL isUnionPayEnabled;

/// The merchant account ID to use for UnionPay.
@property (nonatomic, readonly, copy, nullable) NSString *unionPayMerchantAccountId;

@end
