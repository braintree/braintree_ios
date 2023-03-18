#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeCardVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeCardVersionString[];

#if __has_include(<Braintree/BraintreeCard.h>)
#import <Braintree/BTCardClient.h>
#import <Braintree/BTCard.h>
#import <Braintree/BTCardNonce.h>
#import <Braintree/BTCardRequest.h>
#else
#import <BraintreeCard/BTCardClient.h>
#import <BraintreeCard/BTCard.h>
#import <BraintreeCard/BTCardNonce.h>
#import <BraintreeCard/BTCardRequest.h>
#endif
