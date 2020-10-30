#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeUnionPayVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeUnionPayVersionString[];

#if SWIFT_PACKAGE
#import "BraintreeCard.h"
#import "BTCardCapabilities.h"
#import "BTCardClient+UnionPay.h"
#import "BTConfiguration+UnionPay.h"
#else
#import <BraintreeCard/BraintreeCard.h>
#import <BraintreeUnionPay/BTCardCapabilities.h>
#import <BraintreeUnionPay/BTCardClient+UnionPay.h>
#import <BraintreeUnionPay/BTConfiguration+UnionPay.h>
#endif
