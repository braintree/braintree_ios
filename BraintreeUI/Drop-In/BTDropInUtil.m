#import "BTDropInUtil.h"

@implementation BTDropInUtil

+ (BTUIPaymentOptionType)uiForCardNetwork:(BTCardNetwork)cardNetwork {
    switch (cardNetwork) {
        case BTCardNetworkUnknown:    return BTUIPaymentOptionTypeUnknown;
        case BTCardNetworkAMEX:       return BTUIPaymentOptionTypeAMEX;
        case BTCardNetworkDinersClub: return BTUIPaymentOptionTypeDinersClub;
        case BTCardNetworkDiscover:   return BTUIPaymentOptionTypeDiscover;
        case BTCardNetworkMasterCard: return BTUIPaymentOptionTypeMasterCard;
        case BTCardNetworkVisa:       return BTUIPaymentOptionTypeVisa;
        case BTCardNetworkJCB:        return BTUIPaymentOptionTypeJCB;
        case BTCardNetworkLaser:      return BTUIPaymentOptionTypeLaser;
        case BTCardNetworkMaestro:    return BTUIPaymentOptionTypeMaestro;
        case BTCardNetworkUnionPay:   return BTUIPaymentOptionTypeUnionPay;
        case BTCardNetworkSolo:       return BTUIPaymentOptionTypeSolo;
        case BTCardNetworkSwitch:     return BTUIPaymentOptionTypeSwitch;
        case BTCardNetworkUKMaestro:  return BTUIPaymentOptionTypeUKMaestro;
        default:                      return BTUIPaymentOptionTypeUnknown;
    }
}

@end
