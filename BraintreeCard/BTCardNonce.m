#import "BTCardNonce_Internal.h"

@implementation BTCardNonce

- (instancetype)initWithNonce:(NSString *)nonce
                  description:(NSString *)description
                  cardNetwork:(BTCardNetwork)cardNetwork
                      lastTwo:(NSString *)lastTwo
                    isDefault:(BOOL)isDefault
                     cardJSON:(nonnull BTJSON *)cardJSON
{
    self = [super initWithNonce:nonce localizedDescription:description type:[BTCardNonce typeStringFromCardNetwork:cardNetwork] isDefault:isDefault];
    if (self) {
        _cardNetwork = cardNetwork;
        _lastTwo = lastTwo;
        _binData = [[BTBinData alloc] initWithJSON:cardJSON[@"binData"]];
        _threeDSecureInfo = [[BTThreeDSecureInfo alloc] initWithJSON:cardJSON[@"threeDSecureInfo"]];
    }
    return self;
}

+ (NSString *)typeStringFromCardNetwork:(BTCardNetwork)cardNetwork {
    switch (cardNetwork) {
        case BTCardNetworkAMEX:
            return @"AMEX";
        case BTCardNetworkDinersClub:
            return @"DinersClub";
        case BTCardNetworkDiscover:
            return @"Discover";
        case BTCardNetworkMasterCard:
            return @"MasterCard";
        case BTCardNetworkVisa:
            return @"Visa";
        case BTCardNetworkJCB:
            return @"JCB";
        case BTCardNetworkLaser:
            return @"Laser";
        case BTCardNetworkMaestro:
            return @"Maestro";
        case BTCardNetworkUnionPay:
            return @"UnionPay";
        case BTCardNetworkHiper:
            return @"Hiper";
        case BTCardNetworkHipercard:
            return @"Hipercard";
        case BTCardNetworkSolo:
            return @"Solo";
        case BTCardNetworkSwitch:
            return @"Switch";
        case BTCardNetworkUKMaestro:
            return @"UKMaestro";
        case BTCardNetworkUnknown:
        default:
            return @"Unknown";
    }
}

+ (BTCardNetwork)cardNetworkFromGatewayCardType:(NSString *)string {
    // Normalize the card network string in cardJSON to be lowercase so that our enum mapping is case insensitive
    BTJSON *cardType = [[BTJSON alloc] initWithValue:string.lowercaseString];
    return [cardType asEnum:@{
                              @"american express": @(BTCardNetworkAMEX),
                              @"diners club": @(BTCardNetworkDinersClub),
                              @"unionpay": @(BTCardNetworkUnionPay),
                              @"discover": @(BTCardNetworkDiscover),
                              @"maestro": @(BTCardNetworkMaestro),
                              @"mastercard": @(BTCardNetworkMasterCard),
                              @"jcb": @(BTCardNetworkJCB),
                              @"hiper": @(BTCardNetworkHiper),
                              @"hipercard": @(BTCardNetworkHipercard),
                              @"laser": @(BTCardNetworkLaser),
                              @"solo": @(BTCardNetworkSolo),
                              @"switch": @(BTCardNetworkSwitch),
                              @"uk maestro": @(BTCardNetworkUKMaestro),
                              @"visa": @(BTCardNetworkVisa),}
                  orDefault:BTCardNetworkUnknown];
}

+ (instancetype)cardNonceWithJSON:(BTJSON *)cardJSON {
    return [[[self class] alloc] initWithNonce:[cardJSON[@"nonce"] asString]
                                   description:[cardJSON[@"description"] asString]
                                   cardNetwork:[self.class cardNetworkFromGatewayCardType:[cardJSON[@"details"][@"cardType"] asString]]
                                       lastTwo:[cardJSON[@"details"][@"lastTwo"] asString]
                                     isDefault:[cardJSON[@"default"] isTrue]
                                      cardJSON:cardJSON];
}

+ (instancetype)cardNonceWithGraphQLJSON:(BTJSON *)cardJSON {
    NSString *lastFour = [cardJSON[@"creditCard"][@"last4"] asString];
    NSString *lastTwo = lastFour.length == 4 ? [lastFour substringFromIndex:2] : @"";
    NSString *description = lastTwo.length > 0 ? [NSString stringWithFormat:@"ending in %@", lastTwo] : @"";
    return [[[self class] alloc] initWithNonce:[cardJSON[@"token"] asString]
                                   description:description
                                   cardNetwork:[self.class cardNetworkFromGatewayCardType:[cardJSON[@"creditCard"][@"brand"] asString]]
                                       lastTwo:lastTwo
                                     isDefault:NO
                                      cardJSON:cardJSON[@"creditCard"]];
}

@end
