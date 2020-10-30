#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeApplePayVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeApplePayVersionString[];

#import <PassKit/PassKit.h>

#if SWIFT_PACKAGE
#import "BraintreeCore.h"
#import "BTApplePayClient.h"
#import "BTConfiguration+ApplePay.h"
#import "BTApplePayCardNonce.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeApplePay/BTApplePayClient.h>
#import <BraintreeApplePay/BTConfiguration+ApplePay.h>
#import <BraintreeApplePay/BTApplePayCardNonce.h>
#endif
