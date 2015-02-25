#import "BTCoinbasePaymentMethod.h"

@implementation BTCoinbasePaymentMethod

@synthesize userIdentifier = _userIdentifier;

- (void)setUserIdentifier:(NSString *)userIdentifier {
    _userIdentifier = userIdentifier;
}

@end
