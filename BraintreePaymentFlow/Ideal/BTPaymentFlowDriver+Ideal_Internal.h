#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPaymentFlowDriver.h"
#import "BTIdealBank.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTPaymentFlowDriver (Ideal_Internal)

- (void)checkStatus:(NSString *)idealId completion:(void (^)(BTPaymentFlowResult * _Nullable result, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
