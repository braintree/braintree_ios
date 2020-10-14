#if SWIFT_PACKAGE
#import "BTAuthenticationInsight.h"
#else
#import <BraintreeCard/BTAuthenticationInsight.h>
#endif

@class BTJSON;

@interface BTAuthenticationInsight ()

- (instancetype)initWithJSON:(BTJSON *)json;

@end
