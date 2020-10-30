#import <UIKit/UIKit.h>

/// Project version number for BraintreeCore.
FOUNDATION_EXPORT double BraintreeCoreVersionNumber;

/// Project version string for BraintreeCore.
FOUNDATION_EXPORT const unsigned char BraintreeCoreVersionString[];

// This relies on merchant app defining SWIFT_PACKAGE=1 macro
#if SWIFT_PACKAGE
#import "BTAPIClient.h"
#import "BTAppSwitch.h"
#import "BTBinData.h"
#import "BTClientMetadata.h"
#import "BTClientToken.h"
#import "BTConfiguration.h"
#import "BTEnums.h"
#import "BTErrors.h"
#import "BTHTTPErrors.h"
#import "BTJSON.h"
#import "BTLogger.h"
#import "BTPostalAddress.h"
#import "BTPaymentMethodNonce.h"
#import "BTPaymentMethodNonceParser.h"
#import "BTPayPalIDToken.h"
#import "BTTokenizationService.h"
#import "BTViewControllerPresentingDelegate.h"
#import "BTPreferredPaymentMethods.h"
#import "BTPreferredPaymentMethodsResult.h"
#import "BTURLUtils.h"

#else
#import <BraintreeCore/BTAPIClient.h>
#import <BraintreeCore/BTAppSwitch.h>
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
#import <BraintreeCore/BTPaymentMethodNonceParser.h>
#import <BraintreeCore/BTPayPalIDToken.h>
#import <BraintreeCore/BTTokenizationService.h>
#import <BraintreeCore/BTPaymentMethodNonce.h>
#import <BraintreeCore/BTViewControllerPresentingDelegate.h>
#import <BraintreeCore/BTPreferredPaymentMethods.h>
#import <BraintreeCore/BTPreferredPaymentMethodsResult.h>
#import <BraintreeCore/BTURLUtils.h>

#endif
