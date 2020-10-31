#import "BTConfiguration+GraphQL.h"

#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTJSON.h>
#else
#import <BraintreeCore/BTJSON.h>
#endif

@implementation BTConfiguration (GraphQL)

- (BOOL)isGraphQLEnabled {
    return [self.json[@"graphQL"][@"url"] asString].length > 0;
}

@end
