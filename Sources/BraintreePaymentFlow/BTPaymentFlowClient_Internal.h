#import <AuthenticationServices/AuthenticationServices.h>

#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTPaymentFlowClient.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowClient.h>
#endif

@class BTPaymentFlowRequest;
@class BTPaymentFlowResult;

@interface BTPaymentFlowClient ()

/**
 Exposed for testing, the ASWebAuthenticationSession instance used for the PayPal flow
 */
@property (nonatomic, strong, nullable) ASWebAuthenticationSession *authenticationSession;

@end
