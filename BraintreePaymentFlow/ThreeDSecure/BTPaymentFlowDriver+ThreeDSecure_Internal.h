#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPaymentFlowDriver+ThreeDSecure.h"
#import "BTThreeDSecureLookup.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTPaymentFlowDriver (ThreeDSecure_Internal)

- (void)lookupThreeDSecureForNonce:(NSString *)nonce
                 transactionAmount:(NSDecimalNumber *)amount
                        completion:(void (^)(BTThreeDSecureLookup * _Nullable threeDSecureLookup, NSError * _Nullable error))completionBlock;
@end

NS_ASSUME_NONNULL_END

