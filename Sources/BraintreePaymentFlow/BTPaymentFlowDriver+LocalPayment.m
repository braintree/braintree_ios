#import "BTPaymentFlowDriver_Internal.h"

#if __has_include(<Braintree/BraintreePaymentFlow.h>) // CocoaPods
#import <Braintree/BTPaymentFlowDriver+LocalPayment.h>
#import <Braintree/BTConfiguration+LocalPayment.h>
#import <Braintree/BTAPIClient_Internal.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreePaymentFlow/BTPaymentFlowDriver+LocalPayment.h>
#import <BraintreePaymentFlow/BTConfiguration+LocalPayment.h>
#import "../BTAPIClient_Internal.h"

#else // Carthage
#import <BraintreePaymentFlow/BTPaymentFlowDriver+LocalPayment.h>
#import <BraintreePaymentFlow/BTConfiguration+LocalPayment.h>
#import <BraintreeCore/BTAPIClient_Internal.h>

#endif

@implementation BTPaymentFlowDriver (LocalPayment)

@end
