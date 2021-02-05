#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeVenmoVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeVenmoVersionString[];

#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTConfiguration+Venmo.h>
#import <Braintree/BTVenmoDriver.h>
#import <Braintree/BTVenmoAccountNonce.h>
#import <Braintree/BTVenmoRequest.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeVenmo/BTConfiguration+Venmo.h>
#import <BraintreeVenmo/BTVenmoDriver.h>
#import <BraintreeVenmo/BTVenmoAccountNonce.h>
#import <BraintreeVenmo/BTVenmoRequest.h>
#endif
