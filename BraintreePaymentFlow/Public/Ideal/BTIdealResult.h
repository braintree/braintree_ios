#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPaymentFlowResult.h"

/**
 @brief The result of an iDEAL payment flow
 */
@interface BTIdealResult : BTPaymentFlowResult

/**
 @brief The status of the iDEAL payment. Possible values are [PENDING, COMPLETE, FAILED].
 */
@property (nonatomic, copy) NSString *status;

/**
 @brief The identifier for the iDEAL payment.
 */
@property (nonatomic, copy) NSString *idealId;

/**
 @brief A shortened form of the identifier for the iDEAL payment.
 */
@property (nonatomic, copy) NSString *shortIdealId;

@end
