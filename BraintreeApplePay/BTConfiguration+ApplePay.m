#import "BTConfiguration+ApplePay.h"

@implementation BTConfiguration (ApplePay)

- (BOOL)isApplePayEnabled {
    BTJSON *applePayConfiguration = self.json[@"applePay"];
    return [applePayConfiguration[@"status"] isString] && ![[applePayConfiguration[@"status"] asString] isEqualToString:@"off"];
}

@end
