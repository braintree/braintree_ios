#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPaymentFlowRequest.h"
#import "BTPaymentFlowDriver.h"

NS_ASSUME_NONNULL_BEGIN

@class BTIdealResult;
@protocol BTIdealRequestDelegate;

/**
 @brief Used to initialize an iDEAL payment flow
 */
@interface BTIdealRequest : BTPaymentFlowRequest <BTPaymentFlowRequestDelegate>

/**
 @brief A unique ID provided by you to associate with this transaction.
 */
@property (nonatomic, copy) NSString *orderId;

/**
 @brief The issuing bank for the iDEAL transaction.
 
 @discussion See `BTPaymentFlowDriver+Ideal` and `BTIdealBank`.
 */
@property (nonatomic, copy) NSString *issuer;

/**
 @brief The currency of the transaction.
 */
@property (nonatomic, copy) NSString *currency;

/**
 @brief The amount for the transaction.
 */
@property (nonatomic, copy) NSString *amount;

/**
 @brief A delegate for receiving information about the iDEAL payment.
 */
@property (nonatomic, weak) id<BTIdealRequestDelegate> idealPaymentFlowDelegate;

@end

@protocol BTIdealRequestDelegate

@required

/**
 @brief Returns the BTIdealResult with the iDEAL ID and status of `PENDING` before the flow starts. The ID should be used in conjunction with webhooks to detect the change in status.
 */
- (void)idealPaymentStarted:(BTIdealResult *)result;

@end

NS_ASSUME_NONNULL_END
