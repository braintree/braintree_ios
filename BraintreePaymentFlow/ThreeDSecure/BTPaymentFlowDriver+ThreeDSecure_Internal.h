#import "BTPaymentFlowDriver+ThreeDSecure.h"
@class BTThreeDSecureResult;

NS_ASSUME_NONNULL_BEGIN

@class BTThreeDSecureRequest;

@interface BTPaymentFlowDriver (ThreeDSecure_Internal)

- (void)performThreeDSecureLookup:(BTThreeDSecureRequest *)request
                       completion:(void (^)(BTThreeDSecureResult  * _Nullable threeDSecureResult, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END

