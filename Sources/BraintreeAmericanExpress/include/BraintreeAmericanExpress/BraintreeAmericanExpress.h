#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeAmericanExpressVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeAmericanExpressVersionString[];

#if SWIFT_PACKAGE
#import "BraintreeCore.h"
#import "BTAmericanExpressClient.h"
#import "BTAmericanExpressRewardsBalance.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeAmericanExpress/BTAmericanExpressClient.h>
#import <BraintreeAmericanExpress/BTAmericanExpressRewardsBalance.h>
#endif
