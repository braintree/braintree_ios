#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BTTokenizedCard.h"
#else
#import <BraintreeCard/BTTokenizedCard.h>
#endif

@interface BTVenmoTokenizedCard : BTTokenizedCard

@end
