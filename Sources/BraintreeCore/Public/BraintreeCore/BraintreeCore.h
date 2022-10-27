#import <UIKit/UIKit.h>
#import <BraintreeCoreSwift/BraintreeCoreSwift-Swift.h>

/// Project version number for BraintreeCore.
FOUNDATION_EXPORT double BraintreeCoreVersionNumber;

/// Project version string for BraintreeCore.
FOUNDATION_EXPORT const unsigned char BraintreeCoreVersionString[];

#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTEnums.h>
#import <Braintree/BTViewControllerPresentingDelegate.h>
#import <Braintree/BTPreferredPaymentMethods.h>
#import <Braintree/BTPreferredPaymentMethodsResult.h>
#import <Braintree/Braintree.h>
#else
#import <BraintreeCore/BTEnums.h>
#import <BraintreeCore/BTViewControllerPresentingDelegate.h>
#import <BraintreeCore/BTPreferredPaymentMethods.h>
#import <BraintreeCore/BTPreferredPaymentMethodsResult.h>
#import <BraintreeCore/Braintree.h>
#endif
