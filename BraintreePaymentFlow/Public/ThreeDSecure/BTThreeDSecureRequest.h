#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPaymentFlowRequest.h"
#import "BTPaymentFlowDriver.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @brief Used to initialize a 3D Secure payment flow
 */
@interface BTThreeDSecureRequest : BTPaymentFlowRequest <BTPaymentFlowRequestDelegate>

/**
 @brief A nonce to be verified by ThreeDSecure
 */
@property (nonatomic, copy) NSString *nonce;

/**
 @brief The amount for the transaction.
 */
@property (nonatomic, copy) NSDecimalNumber *amount;

@end

NS_ASSUME_NONNULL_END
