#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTPaymentFlowClient+ThreeDSecure.h>
#else
#import <BraintreeThreeDSecure/BTPaymentFlowClient+ThreeDSecure.h>
#endif

@class BTThreeDSecureResult;

NS_ASSUME_NONNULL_BEGIN

@class BTThreeDSecureRequest;

@interface BTPaymentFlowClient (ThreeDSecure_Internal)

- (void)performThreeDSecureLookup:(BTThreeDSecureRequest *)request
                       completion:(void (^)(BTThreeDSecureResult  * _Nullable threeDSecureResult, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END

