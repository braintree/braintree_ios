#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreePaymentFlowVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreePaymentFlowVersionString[];

#if __has_include(<Braintree/BraintreePaymentFlow.h>)
// Payment Flow
#import <Braintree/BTPaymentFlowClient.h>
#import <Braintree/BTPaymentFlowRequest.h>
#import <Braintree/BTPaymentFlowResult.h>

// LocalPayment
#import <Braintree/BTLocalPaymentRequest.h>
#import <Braintree/BTLocalPaymentResult.h>
#import <Braintree/BTPaymentFlowClient+LocalPayment.h>

#else
// Payment Flow
#import <BraintreePaymentFlow/BTPaymentFlowClient.h>
#import <BraintreePaymentFlow/BTPaymentFlowRequest.h>
#import <BraintreePaymentFlow/BTPaymentFlowResult.h>

// LocalPayment
#import <BraintreePaymentFlow/BTLocalPaymentRequest.h>
#import <BraintreePaymentFlow/BTLocalPaymentResult.h>
#import <BraintreePaymentFlow/BTPaymentFlowClient+LocalPayment.h>
#endif
