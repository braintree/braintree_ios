#import "BTConfiguration+PayPal.h"

@implementation BTConfiguration (PayPal)

- (BOOL)isPayPalEnabled {
    return self.json[@"paypalEnabled"].isTrue;
}

@end
