#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeUnionPayVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeUnionPayVersionString[];

#if __has_include(<Braintree/BraintreeUnionPay.h>)
#import <Braintree/BraintreeCard.h>
#import <Braintree/BTCardCapabilities.h>
#import <Braintree/BTCardClient+UnionPay.h>
#import <Braintree/BTConfiguration+UnionPay.h>
#else
#import <BraintreeCard/BraintreeCard.h>
#import <BraintreeUnionPay/BTCardCapabilities.h>
#import <BraintreeUnionPay/BTCardClient+UnionPay.h>
#import <BraintreeUnionPay/BTConfiguration+UnionPay.h>
#endif
