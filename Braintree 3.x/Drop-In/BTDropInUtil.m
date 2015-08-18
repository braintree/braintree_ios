#import "BTDropInUtil.h"

@implementation BTDropInUtil

+ (BTUIPaymentMethodType)uiForCardType:(BTCardType)cardType {
    switch (cardType) {
        case BTCardTypeUnknown:    return BTUIPaymentMethodTypeUnknown;
        case BTCardTypeAMEX:       return BTUIPaymentMethodTypeAMEX;
        case BTCardTypeDinersClub: return BTUIPaymentMethodTypeDinersClub;
        case BTCardTypeDiscover:   return BTUIPaymentMethodTypeDiscover;
        case BTCardTypeMasterCard: return BTUIPaymentMethodTypeMasterCard;
        case BTCardTypeVisa:       return BTUIPaymentMethodTypeVisa;
        case BTCardTypeJCB:        return BTUIPaymentMethodTypeJCB;
        case BTCardTypeLaser:      return BTUIPaymentMethodTypeLaser;
        case BTCardTypeMaestro:    return BTUIPaymentMethodTypeMaestro;
        case BTCardTypeUnionPay:   return BTUIPaymentMethodTypeUnionPay;
        case BTCardTypeSolo:       return BTUIPaymentMethodTypeSolo;
        case BTCardTypeSwitch:     return BTUIPaymentMethodTypeSwitch;
        case BTCardTypeUKMaestro:  return BTUIPaymentMethodTypeUKMaestro;
        default:                   return BTUIPaymentMethodTypeUnknown;
    }
}

@end
