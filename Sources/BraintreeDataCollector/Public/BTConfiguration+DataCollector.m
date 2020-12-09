#if __has_include(<Braintree/BraintreeDataCollector.h>)
#import <Braintree/BTConfiguration+DataCollector.h>
#else
#import <BraintreeDataCollector/BTConfiguration+DataCollector.h>
#endif

@implementation BTConfiguration (DataCollector)

- (BOOL)isKountEnabled {
    return [self.json[@"kount"][@"kountMerchantId"] isString];
}

-(NSString *)kountMerchantId {
    return [self.json[@"kount"][@"kountMerchantId"] asString];
}

@end
