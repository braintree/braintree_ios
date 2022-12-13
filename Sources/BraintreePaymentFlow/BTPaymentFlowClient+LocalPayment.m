#import "BTPaymentFlowClient_Internal.h"

#if __has_include(<Braintree/BraintreePaymentFlow.h>) // CocoaPods
#import <Braintree/BTPaymentFlowClient+LocalPayment.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreePaymentFlow/BTPaymentFlowClient+LocalPayment.h>

#else // Carthage
#import <BraintreePaymentFlow/BTPaymentFlowClient+LocalPayment.h>

#endif

@implementation BTPaymentFlowClient (LocalPayment)

@end
