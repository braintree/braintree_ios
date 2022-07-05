#import <UIKit/UIKit.h>

/// Project version number for BraintreeCore.
FOUNDATION_EXPORT double BraintreeCoreVersionNumber;

/// Project version string for BraintreeCore.
FOUNDATION_EXPORT const unsigned char BraintreeCoreVersionString[];

#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTAPIClient.h>
#import <Braintree/BTBinData.h>
#import <Braintree/BTClientToken.h>
#import <Braintree/BTConfiguration.h>
#import <Braintree/BTEnums.h>
#import <Braintree/BTErrors.h>
#import <Braintree/BTHTTPErrors.h>
#import <Braintree/BTJSON.h>
#import <Braintree/BTPostalAddress.h>
#import <Braintree/BTPaymentMethodNonce.h>
#import <Braintree/BTPaymentMethodNonce.h>
#import <Braintree/BTViewControllerPresentingDelegate.h>
#import <Braintree/BTPreferredPaymentMethods.h>
#import <Braintree/BTPreferredPaymentMethodsResult.h>
#else
#import <BraintreeCore/BTAPIClient.h>
#import <BraintreeCore/BTBinData.h>
#import <BraintreeCore/BTClientToken.h>
#import <BraintreeCore/BTConfiguration.h>
#import <BraintreeCore/BTEnums.h>
#import <BraintreeCore/BTErrors.h>
#import <BraintreeCore/BTHTTPErrors.h>
#import <BraintreeCore/BTJSON.h>
#import <BraintreeCore/BTPostalAddress.h>
#import <BraintreeCore/BTPaymentMethodNonce.h>
#import <BraintreeCore/BTPaymentMethodNonce.h>
#import <BraintreeCore/BTViewControllerPresentingDelegate.h>
#import <BraintreeCore/BTPreferredPaymentMethods.h>
#import <BraintreeCore/BTPreferredPaymentMethodsResult.h>
#endif

//// Swift Module Imports
//#if __has_include(<Braintree/Braintree-Swift.h>) // Cocoapods-generated Swift Header
//#import <Braintree/Braintree-Swift.h>
//
//#elif SWIFT_PACKAGE                              // SPM
///* Use @import for SPM support
// * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
// */
//@import BraintreeCoreSwift;
//
//#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
///* Use quoted style when importing Swift headers for ReactNative support
// * See https://github.com/braintree/braintree_ios/issues/671
// */
//#import "Braintree-Swift.h"
//
//#else // Carthage or Local Builds
//#import <BraintreeCoreSwift/BraintreeCoreSwift-Swift.h>
//#endif
