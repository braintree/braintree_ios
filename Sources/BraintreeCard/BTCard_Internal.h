#import <BraintreeCard/BTCard.h>

@class BTJSON;

@interface BTCard ()

- (NSDictionary *)parameters;

- (NSDictionary *)graphQLParameters;

extern NSString * const BTCardGraphQLTokenizationMutation;

extern NSString * const BTCardGraphQLTokenizationWithAuthenticationInsightMutation;

@end
