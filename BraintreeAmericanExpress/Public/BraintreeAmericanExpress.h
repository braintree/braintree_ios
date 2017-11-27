#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double BraintreeAmericanExpressVersionNumber;

FOUNDATION_EXPORT const unsigned char BraintreeAmericanExpressVersionString[];

#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTAmericanExpressClient.h"
#import "BTAmericanExpressRewardsBalance.h"
