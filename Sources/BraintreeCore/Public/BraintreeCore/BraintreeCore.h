#import <UIKit/UIKit.h>

/// Project version number for BraintreeCore.
FOUNDATION_EXPORT double BraintreeCoreVersionNumber;

/// Project version string for BraintreeCore.
FOUNDATION_EXPORT const unsigned char BraintreeCoreVersionString[];

#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTAPIClient.h>
#import <Braintree/BTAppContextSwitcher.h>
#import <Braintree/BTBinData.h>
#import <Braintree/BTClientMetadata.h>
#import <Braintree/BTClientToken.h>
#import <Braintree/BTConfiguration.h>
#import <Braintree/BTEnums.h>
#import <Braintree/BTErrors.h>
#import <Braintree/BTHTTPErrors.h>
#import <Braintree/BTJSON.h>
#import <Braintree/BTLogger.h>
#import <Braintree/BTPostalAddress.h>
#import <Braintree/BTPaymentMethodNonce.h>
#import <Braintree/BTPayPalIDToken.h>
#import <Braintree/BTPaymentMethodNonce.h>
#import <Braintree/BTViewControllerPresentingDelegate.h>
#import <Braintree/BTPreferredPaymentMethods.h>
#import <Braintree/BTPreferredPaymentMethodsResult.h>
#import <Braintree/BTURLUtils.h>
#else
#import <BraintreeCore/BTAPIClient.h>
#import <BraintreeCore/BTAppContextSwitcher.h>
#import <BraintreeCore/BTBinData.h>
#import <BraintreeCore/BTClientMetadata.h>
#import <BraintreeCore/BTClientToken.h>
#import <BraintreeCore/BTConfiguration.h>
#import <BraintreeCore/BTEnums.h>
#import <BraintreeCore/BTErrors.h>
#import <BraintreeCore/BTHTTPErrors.h>
#import <BraintreeCore/BTJSON.h>
#import <BraintreeCore/BTLogger.h>
#import <BraintreeCore/BTPostalAddress.h>
#import <BraintreeCore/BTPaymentMethodNonce.h>
#import <BraintreeCore/BTPayPalIDToken.h>
#import <BraintreeCore/BTPaymentMethodNonce.h>
#import <BraintreeCore/BTViewControllerPresentingDelegate.h>
#import <BraintreeCore/BTPreferredPaymentMethods.h>
#import <BraintreeCore/BTPreferredPaymentMethodsResult.h>
#import <BraintreeCore/BTURLUtils.h>
#endif
