#if __has_include(<Braintree/BraintreeUnionPay.h>)
#import <Braintree/BTConfiguration+UnionPay.h>
#else
#import <BraintreeUnionPay/BTConfiguration+UnionPay.h>
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
@implementation BTConfiguration (UnionPay)
#pragma clang diagnostic pop

- (BOOL)isUnionPayEnabled {
    return [self.json[@"unionPay"][@"enabled"] isTrue];
}

@end
