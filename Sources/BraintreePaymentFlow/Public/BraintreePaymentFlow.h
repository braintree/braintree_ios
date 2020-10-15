#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreePaymentFlowVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreePaymentFlowVersionString[];

#if SWIFT_PACKAGE
// Payment Flow
#import "BraintreeCore.h"
#import "BTPaymentFlowDriver.h"
#import "BTPaymentFlowRequest.h"
#import "BTPaymentFlowResult.h"

// LocalPayment
#import "BTConfiguration+LocalPayment.h"
#import "BTLocalPaymentRequest.h"
#import "BTLocalPaymentResult.h"
#import "BTPaymentFlowDriver+LocalPayment.h"

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
