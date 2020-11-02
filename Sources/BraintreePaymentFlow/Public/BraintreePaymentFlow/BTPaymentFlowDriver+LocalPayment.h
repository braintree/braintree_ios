#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTPaymentFlowDriver.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowDriver.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Category on BTPaymentFlowDriver for LocalPayment
 */
@interface BTPaymentFlowDriver (LocalPayment)

@end

NS_ASSUME_NONNULL_END
