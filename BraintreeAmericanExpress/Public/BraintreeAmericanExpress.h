#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeAmericanExpressVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeAmericanExpressVersionString[];

#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTAmericanExpressClient.h"
#import "BTAmericanExpressRewardsBalance.h"
