#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTPaymentFlowClient.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowClient.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Category on BTPaymentFlowClient for LocalPayment
 */
@interface BTPaymentFlowClient (LocalPayment)

@end

NS_ASSUME_NONNULL_END
