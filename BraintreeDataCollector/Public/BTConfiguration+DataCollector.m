#import "BTConfiguration+DataCollector.h"

@implementation BTConfiguration (DataCollector)

- (BOOL)isKountEnabled {
    return [self.json[@"kount"][@"enabled"] isTrue];
}

-(NSString *)kountMerchantId {
    return [self.json[@"kount"][@"kountMerchantId"] asString];
}

@end
