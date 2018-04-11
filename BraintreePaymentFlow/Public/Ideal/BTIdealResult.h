#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPaymentFlowResult.h"

/**
 The result of an iDEAL payment flow
 */
@interface BTIdealResult : BTPaymentFlowResult

/**
 The status of the iDEAL payment. Possible values are [PENDING, COMPLETE, FAILED].
 */
@property (nonatomic, copy) NSString *status;

/**
 The identifier for the iDEAL payment.
 */
@property (nonatomic, copy) NSString *idealId;

/**
 A shortened form of the identifier for the iDEAL payment.
 */
@property (nonatomic, copy) NSString *shortIdealId;

@end
