#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeCardVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeCardVersionString[];

#if __has_include(<Braintree/BraintreeCard.h>)
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTCardClient.h>
#import <Braintree/BTCard.h>
#import <Braintree/BTCardNonce.h>
#import <Braintree/BTCardRequest.h>
#import <Braintree/BTThreeDSecureInfo.h>
#import <Braintree/BTAuthenticationInsight.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCard/BTCardClient.h>
#import <BraintreeCard/BTCard.h>
#import <BraintreeCard/BTCardNonce.h>
#import <BraintreeCard/BTCardRequest.h>
#import <BraintreeCard/BTThreeDSecureInfo.h>
#import <BraintreeCard/BTAuthenticationInsight.h>
#endif
