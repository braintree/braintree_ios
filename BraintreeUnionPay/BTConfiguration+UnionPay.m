#import "BTConfiguration+UnionPay.h"

@implementation BTConfiguration (UnionPay)

- (BOOL)isUnionPayEnabled {
    return [self.json[@"unionPay"][@"enabled"] isTrue];
}

- (NSString *)unionPayMerchantAccountId {
    return [self.json[@"unionPay"][@"merchantAccountId"] asString];
}

@end
