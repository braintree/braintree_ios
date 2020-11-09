#if __has_include(<Braintree/BraintreeUnionPay.h>)
#import <Braintree/BTConfiguration+UnionPay.h>
#else
#import <BraintreeUnionPay/BTConfiguration+UnionPay.h>
#endif

@implementation BTConfiguration (UnionPay)

- (BOOL)isUnionPayEnabled {
    return [self.json[@"unionPay"][@"enabled"] isTrue];
}

@end
