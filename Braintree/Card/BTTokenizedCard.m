#import "BTTokenizedCard_Internal.h"

@interface BTTokenizedCard ()

@property (nonatomic, nullable, readonly, strong) BTJSON *threeDSecureJSON;

@end

@implementation BTTokenizedCard

@synthesize paymentMethodNonce = _paymentMethodNonce;
@synthesize localizedDescription = _localizedDescription;

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                               cardNetwork:(BTCardNetwork)cardNetwork
                                   lastTwo:(NSString *)lastTwo
                          threeDSecureJSON:(BTJSON *)threeDSecureJSON
{
    self = [self init];
    if (self) {
        _paymentMethodNonce = nonce;
        _localizedDescription = description;
        _cardNetwork = cardNetwork;
        _lastTwo = lastTwo;
        _threeDSecureJSON = threeDSecureJSON;
    }
    return self;
}

+ (instancetype)cardWithJSON:(BTJSON *)cardJSON {
    return [[BTTokenizedCard alloc] initWithPaymentMethodNonce:cardJSON[@"nonce"].asString
                                                   description:cardJSON[@"description"].asString
                                                   cardNetwork:[cardJSON[@"details"][@"cardType"] asEnum:@{
                                                                                                           @"american express": @(BTCardNetworkAMEX),
                                                                                                           @"diners club": @(BTCardNetworkDinersClub),
                                                                                                           @"china unionpay": @(BTCardNetworkUnionPay),
                                                                                                           @"discover": @(BTCardNetworkDiscover),
                                                                                                           @"jcb": @(BTCardNetworkJCB),
                                                                                                           @"maestro": @(BTCardNetworkMaestro),
                                                                                                           @"mastercard": @(BTCardNetworkMasterCard),
                                                                                                           @"solo": @(BTCardNetworkSolo),
                                                                                                           @"switch": @(BTCardNetworkSwitch),
                                                                                                           @"uk maestro": @(BTCardNetworkUKMaestro),
                                                                                                           @"visa": @(BTCardNetworkVisa),}
                                                                                               orDefault:BTCardNetworkUnknown]
                                                       lastTwo:cardJSON[@"details"][@"lastTwo"].asString
                                              threeDSecureJSON:cardJSON[@"threeDSecureInfo"]];
}



@end
