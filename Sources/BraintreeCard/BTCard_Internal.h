#if SWIFT_PACKAGE
#import "BTCard.h"
#else
#import <BraintreeCard/BTCard.h>
#endif

@class BTJSON;

@interface BTCard ()

- (NSDictionary *)parameters;

- (NSDictionary *)graphQLParameters;

extern NSString * const BTCardGraphQLTokenizationMutation;

extern NSString * const BTCardGraphQLTokenizationWithAuthenticationInsightMutation;

@end
