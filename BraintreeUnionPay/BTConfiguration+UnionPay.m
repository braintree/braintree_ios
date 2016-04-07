#import "BTConfiguration+UnionPay.h"

@implementation BTConfiguration (UnionPay)

- (BOOL)isUnionPayEnabled {
    return [self.json[@"unionPayEnabled"] isTrue];
}

@end
