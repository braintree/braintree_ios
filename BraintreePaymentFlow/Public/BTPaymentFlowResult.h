#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Wrapper for a payment flow result.
 */
@interface BTPaymentFlowResult : NSObject

@end

NS_ASSUME_NONNULL_END
