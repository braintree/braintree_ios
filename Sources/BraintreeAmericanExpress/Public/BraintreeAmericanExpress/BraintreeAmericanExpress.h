#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeAmericanExpressVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeAmericanExpressVersionString[];

#if __has_include(<Braintree/BraintreeAmericanExpress.h>)
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTAmericanExpressClient.h>
#import <Braintree/BTAmericanExpressRewardsBalance.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeAmericanExpress/BTAmericanExpressClient.h>
#import <BraintreeAmericanExpress/BTAmericanExpressRewardsBalance.h>
#endif
