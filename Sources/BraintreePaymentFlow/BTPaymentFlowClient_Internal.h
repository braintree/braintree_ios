#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTPaymentFlowClient.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowClient.h>
#endif

@class BTPaymentFlowRequest;
@class BTPaymentFlowResult;

@interface BTPaymentFlowClient ()

/**
 Set up the BTPaymentFlowClient with a request object and a completion block without starting the flow.

 @param request A BTPaymentFlowRequest to set on the BTPaymentFlow
 @param completionBlock This completion will be invoked exactly once when the payment flow is complete or an error occurs.
 */
- (void)setupPaymentFlow:(BTPaymentFlowRequest<BTPaymentFlowRequestDelegate> *_Nonnull)request completion:(void (^_Nullable)(BTPaymentFlowResult * _Nullable, NSError * _Nullable))completionBlock;

/**
 Exposed for testing - instantiates the SFSafariViewController to be presented
*/
- (void)informDelegatePresentingViewControllerRequestPresent:(NSURL * _Nullable)appSwitchURL;

@end
