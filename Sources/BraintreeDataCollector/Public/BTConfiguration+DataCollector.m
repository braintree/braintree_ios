#if __has_include(<Braintree/BraintreeDataCollector.h>) // CocoaPods
#import <Braintree/BTConfiguration+DataCollector.h>

#elif SWIFT_PACKAGE // SPM
#import "../BraintreeDataCollector/BTConfiguration+DataCollector.h"

#else // Carthage
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
