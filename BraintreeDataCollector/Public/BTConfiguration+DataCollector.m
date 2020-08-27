#import "BTConfiguration+DataCollector.h"

#import <BraintreeCore/BTJSON.h>

@implementation BTConfiguration (DataCollector)

- (BOOL)isKountEnabled {
    return [self.json[@"kount"][@"kountMerchantId"] isString];
}

-(NSString *)kountMerchantId {
    return [self.json[@"kount"][@"kountMerchantId"] asString];
}

@end
