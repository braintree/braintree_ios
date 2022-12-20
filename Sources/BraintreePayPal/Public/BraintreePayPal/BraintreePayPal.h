#import <Foundation/Foundation.h>

/// Project version number for BraintreePayPal.
FOUNDATION_EXPORT double BraintreePayPalVersionNumber;

/// Project version string for BraintreePayPal.
FOUNDATION_EXPORT const unsigned char BraintreePayPalVersionString[];

#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalClient.h>
#import <Braintree/BTPayPalAccountNonce.h>
#else
#import <BraintreePayPal/BTPayPalClient.h>
#import <BraintreePayPal/BTPayPalAccountNonce.h>
#endif
