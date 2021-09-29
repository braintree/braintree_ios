#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTPaymentFlowDriver.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowDriver.h>
#endif

#import <BraintreeCore/BTWebAuthenticator.h>

@class BTPaymentFlowRequest;
@class BTPaymentFlowResult;

@interface BTPaymentFlowDriver ()

/**
 Set up the BTPaymentFlowDriver with a request object and a completion block without starting the flow.

 @param request A BTPaymentFlowRequest to set on the BTPaymentFlow
 @param completionBlock This completion will be invoked exactly once when the payment flow is complete or an error occurs.
 */
- (void)setupPaymentFlow:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *_Nonnull)request completion:(void (^_Nullable)(BTPaymentFlowResult * _Nullable, NSError * _Nullable))completionBlock;


- (instancetype _Nonnull)initWithAPIClient:(BTAPIClient * _Nonnull)apiClient webAuthenticator:(BTWebAuthenticator * _Nonnull)webAuthenticator NS_DESIGNATED_INITIALIZER;

@end
