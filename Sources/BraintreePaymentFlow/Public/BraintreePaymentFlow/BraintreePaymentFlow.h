#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreePaymentFlowVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreePaymentFlowVersionString[];

#if __has_include(<Braintree/BraintreePaymentFlow.h>)
// Payment Flow
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTPaymentFlowDriver.h>
#import <Braintree/BTPaymentFlowRequest.h>
#import <Braintree/BTPaymentFlowResult.h>

// LocalPayment
#import <Braintree/BTConfiguration+LocalPayment.h>
#import <Braintree/BTLocalPaymentRequest.h>
#import <Braintree/BTLocalPaymentResult.h>
#import <Braintree/BTPaymentFlowDriver+LocalPayment.h>

#else
// Payment Flow
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreePaymentFlow/BTPaymentFlowDriver.h>
#import <BraintreePaymentFlow/BTPaymentFlowRequest.h>
#import <BraintreePaymentFlow/BTPaymentFlowResult.h>

// LocalPayment
#import <BraintreePaymentFlow/BTConfiguration+LocalPayment.h>
#import <BraintreePaymentFlow/BTLocalPaymentRequest.h>
#import <BraintreePaymentFlow/BTLocalPaymentResult.h>
#import <BraintreePaymentFlow/BTPaymentFlowDriver+LocalPayment.h>
#endif
