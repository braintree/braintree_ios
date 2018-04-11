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
 Used to initialize an iDEAL payment flow
 */
@interface BTIdealRequest : BTPaymentFlowRequest <BTPaymentFlowRequestDelegate>

/**
 A unique ID provided by you to associate with this transaction.
 */
@property (nonatomic, copy) NSString *orderId;

/**
 The issuing bank for the iDEAL transaction.
 
 See `BTPaymentFlowDriver+Ideal` and `BTIdealBank`.
 */
@property (nonatomic, copy) NSString *issuer;

/**
 The currency of the transaction.
 */
@property (nonatomic, copy) NSString *currency;

/**
 The amount for the transaction.
 */
@property (nonatomic, copy) NSString *amount;

/**
 A delegate for receiving information about the iDEAL payment.
 */
@property (nonatomic, weak) id<BTIdealRequestDelegate> idealPaymentFlowDelegate;

@end

/**
 Protocol for iDEAl payment flow
 */
@protocol BTIdealRequestDelegate

@required

/**
 Returns the BTIdealResult with the iDEAL ID and status of `PENDING` before the flow starts. The ID should be used in conjunction with webhooks to detect the change in status.
 */
- (void)idealPaymentStarted:(BTIdealResult *)result;

@end

NS_ASSUME_NONNULL_END
