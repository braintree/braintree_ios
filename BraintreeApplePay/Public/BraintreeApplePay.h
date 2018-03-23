#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeApplePayVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeApplePayVersionString[];

#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTApplePayClient.h"
#import "BTConfiguration+ApplePay.h"
#import "BTApplePayCardNonce.h"
