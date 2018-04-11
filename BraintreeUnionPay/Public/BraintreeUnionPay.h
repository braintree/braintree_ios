#import <Foundation/Foundation.h>

/// Version number
FOUNDATION_EXPORT double BraintreeUnionPayVersionNumber;

/// Version string
FOUNDATION_EXPORT const unsigned char BraintreeUnionPayVersionString[];

#if __has_include("BraintreeCard.h")
#import "BraintreeCard.h"
#else
#import <BraintreeCard/BraintreeCard.h>
#endif
#import "BTCardCapabilities.h"
#import "BTCardClient+UnionPay.h"
#import "BTConfiguration+UnionPay.h"
