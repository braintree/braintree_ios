#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeVenmoVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeVenmoVersionString[];

#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BTVenmoClient.h>
#import <Braintree/BTVenmoAccountNonce.h>
#import <Braintree/BTVenmoRequest.h>
#else
#import <BraintreeVenmo/BTVenmoClient.h>
#import <BraintreeVenmo/BTVenmoAccountNonce.h>
#import <BraintreeVenmo/BTVenmoRequest.h>
#endif
