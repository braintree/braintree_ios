#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPaymentFlowDriver.h"
#import "BTIdealBank.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Category on BTPaymentFlowDriver for iDEAL
 */
@interface BTPaymentFlowDriver (Ideal)

/**
 Fetch an array of issuing banks supported by your iDEAL integration.
 
 @param completionBlock This completion will be invoked when the request is complete or an error occurs.
 On success, returns an array of `BTIdealBank` instances; on failure, an error.
 */
- (void)fetchIssuingBanks:(void (^)(NSArray<BTIdealBank *> * _Nullable banks, NSError * _Nullable error))completionBlock;

/**
 Poll until the `status` of the iDEAL payment is no longer `PENDING` or we exceed the maximum number of retries.
 
 @param idealId The id of the ideal payment for which you'd like to check the status.
 @param retries The number of retries to attempt. Valid values 0 - 10.
 @param delay The number of milliseconds to wait between retries. Valid values 1000 - 10000.
 @param completionBlock This completion block will be invoked when the status of the payment has changed from `PENDING` or we exceed the maximum number of retries.
 */
- (void)pollForCompletionWithId:(NSString *)idealId retries:(int)retries delay:(int)delay completion:(void (^)(BTPaymentFlowResult * _Nullable result, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
