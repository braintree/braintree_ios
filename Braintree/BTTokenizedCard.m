#import "BTTokenizedCard_Internal.h"

@implementation BTTokenizedCard

@synthesize paymentMethodNonce = _paymentMethodNonce;
@synthesize localizedDescription = _localizedDescription;

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                               cardNetwork:(BTCardNetwork)cardNetwork
                                   lastTwo:(NSString *)lastTwo
                          threeDSecureInfo:(BTThreeDSecureInfo *)threeDSecureInfo {
    self = [self init];
    if (self) {
        _paymentMethodNonce = nonce;
        _localizedDescription = description;
        _cardNetwork = cardNetwork;
        _lastTwo = lastTwo;
        _threeDSecureInfo = threeDSecureInfo;
    }
    return self;
}

@end
