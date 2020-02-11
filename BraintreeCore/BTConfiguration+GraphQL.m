#import "BTConfiguration+GraphQL.h"

@implementation BTConfiguration (GraphQL)

- (BOOL)isGraphQLEnabled {
    return [self.json[@"graphQL"][@"url"] asString].length > 0;
}

@end
