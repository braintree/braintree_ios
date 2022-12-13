#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTPaymentFlowClient.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowClient.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTPaymentFlowClient (LocalPayment_Internal)

@end

NS_ASSUME_NONNULL_END
