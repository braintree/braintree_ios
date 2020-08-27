#import <BraintreeUnionPay/BTConfiguration+UnionPay.h>
#import <BraintreeCore/BTJSON.h>

@implementation BTConfiguration (UnionPay)

- (BOOL)isUnionPayEnabled {
    return [self.json[@"unionPay"][@"enabled"] isTrue];
}

@end
