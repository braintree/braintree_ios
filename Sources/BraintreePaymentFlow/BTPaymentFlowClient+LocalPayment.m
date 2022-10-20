#import "BTPaymentFlowClient_Internal.h"

#if __has_include(<Braintree/BraintreePaymentFlow.h>) // CocoaPods
#import <Braintree/BTPaymentFlowClient+LocalPayment.h>
#import <Braintree/BTConfiguration+LocalPayment.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreePaymentFlow/BTPaymentFlowClient+LocalPayment.h>
#import <BraintreePaymentFlow/BTConfiguration+LocalPayment.h>

#else // Carthage
#import <BraintreePaymentFlow/BTPaymentFlowClient+LocalPayment.h>
#import <BraintreePaymentFlow/BTConfiguration+LocalPayment.h>

#endif

@implementation BTPaymentFlowClient (LocalPayment)

@end
