#import "BTTokenizedCard_Internal.h"

@implementation BTTokenizedCard

@synthesize nonce = _paymentMethodNonce;
@synthesize localizedDescription = _localizedDescription;
@synthesize type = _type;

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                               cardNetwork:(BTCardNetwork)cardNetwork
                                   lastTwo:(NSString *)lastTwo
{
    self = [self init];
    if (self) {
        _paymentMethodNonce = nonce;
        _localizedDescription = description;
        _cardNetwork = cardNetwork;
        _lastTwo = lastTwo;
        _type = [BTTokenizedCard stringFromCardNetwork:_cardNetwork];
    }
    return self;
}

+ (NSString *)stringFromCardNetwork:(BTCardNetwork)cardNetwork {
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

+ (instancetype)cardWithJSON:(BTJSON *)cardJSON {
    // Normalize the card network string in cardJSON to be lowercase so that our enum mapping is case insensitive
    BTJSON *cardType = [[BTJSON alloc] initWithValue:cardJSON[@"details"][@"cardType"].asString.lowercaseString];
    return [[[self class] alloc] initWithPaymentMethodNonce:cardJSON[@"nonce"].asString
                                                description:cardJSON[@"description"].asString
                                                cardNetwork:[cardType asEnum:@{
                                                                               @"american express": @(BTCardNetworkAMEX),
                                                                               @"diners club": @(BTCardNetworkDinersClub),
                                                                               @"china unionpay": @(BTCardNetworkUnionPay),
                                                                               @"discover": @(BTCardNetworkDiscover),
                                                                               @"maestro": @(BTCardNetworkMaestro),
                                                                               @"mastercard": @(BTCardNetworkMasterCard),
                                                                               @"jcb": @(BTCardNetworkJCB),
                                                                               @"laser": @(BTCardNetworkLaser),
                                                                               @"solo": @(BTCardNetworkSolo),
                                                                               @"switch": @(BTCardNetworkSwitch),
                                                                               @"uk maestro": @(BTCardNetworkUKMaestro),
                                                                               @"visa": @(BTCardNetworkVisa),}
                                                                   orDefault:BTCardNetworkUnknown]
                                                    lastTwo:cardJSON[@"details"][@"lastTwo"].asString];
}

@end
