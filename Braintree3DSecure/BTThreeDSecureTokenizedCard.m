#import "BTThreeDSecureTokenizedCard.h"
#import "BTTokenizedCard_Internal.h"

@interface BTThreeDSecureTokenizedCard ()

@property (nonatomic, strong) BTJSON *threeDSecureJSON;

@end

@implementation BTThreeDSecureTokenizedCard

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                               cardNetwork:(BTCardNetwork)cardNetwork
                                   lastTwo:(NSString *)lastTwo
                          threeDSecureJSON:(BTJSON *)threeDSecureJSON
{
    self = [super initWithPaymentMethodNonce:nonce description:description cardNetwork:cardNetwork lastTwo:lastTwo];
    if (self) {
        _threeDSecureJSON = threeDSecureJSON;
    }
    return self;
}

+ (instancetype)cardWithJSON:(BTJSON *)cardJSON {
    BTThreeDSecureTokenizedCard *card = [super cardWithJSON:cardJSON];
    card.threeDSecureJSON = cardJSON[@"threeDSecureInfo"];
    return card;
}

- (BOOL)liabilityShifted {
    return self.threeDSecureJSON[@"liabilityShifted"].isTrue;
}

- (BOOL)liabilityShiftPossible {
    return self.threeDSecureJSON[@"liabilityShiftPossible"].isTrue;
}

@end
