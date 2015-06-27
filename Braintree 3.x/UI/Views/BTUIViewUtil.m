#import "BTUIViewUtil.h"
@import AudioToolbox;

@implementation BTUIViewUtil

+ (BTUIPaymentMethodType)paymentMethodTypeForCardType:(BTUICardType *)cardType {

    if (cardType == nil) {
        return BTUIPaymentMethodTypeUnknown;
    }

    if ([cardType.brand isEqualToString:BTUILocalizedString(CARD_TYPE_AMERICAN_EXPRESS)]) {
        return BTUIPaymentMethodTypeAMEX;
    } else if ([cardType.brand isEqualToString:BTUILocalizedString(CARD_TYPE_VISA)]) {
        return BTUIPaymentMethodTypeVisa;
    } else if ([cardType.brand isEqualToString:BTUILocalizedString(CARD_TYPE_MASTER_CARD)]) {
        return BTUIPaymentMethodTypeMasterCard;
    } else if ([cardType.brand isEqualToString:BTUILocalizedString(CARD_TYPE_DISCOVER)]) {
        return BTUIPaymentMethodTypeDiscover;
    } else if ([cardType.brand isEqualToString:BTUILocalizedString(CARD_TYPE_JCB)]) {
        return BTUIPaymentMethodTypeJCB;
    } else if ([cardType.brand isEqualToString:BTUILocalizedString(CARD_TYPE_MAESTRO)]) {
        return BTUIPaymentMethodTypeMaestro;
    } else if ([cardType.brand isEqualToString:BTUILocalizedString(CARD_TYPE_DINERS_CLUB)]) {
        return BTUIPaymentMethodTypeDinersClub;
    } else {
        return BTUIPaymentMethodTypeUnknown;
    }
}


+ (NSString *)nameForPaymentMethodType:(BTUIPaymentMethodType)paymentMethodType {
  switch (paymentMethodType) {
    case BTUIPaymentMethodTypeUnknown:
      return @"Card";
    case BTUIPaymentMethodTypeAMEX:
          return BTUILocalizedString(CARD_TYPE_AMERICAN_EXPRESS);
    case BTUIPaymentMethodTypeDinersClub:
          return BTUILocalizedString(CARD_TYPE_DINERS_CLUB);
    case BTUIPaymentMethodTypeDiscover:
      return BTUILocalizedString(CARD_TYPE_DISCOVER);
    case BTUIPaymentMethodTypeMasterCard:
        return BTUILocalizedString(CARD_TYPE_MASTER_CARD);
    case BTUIPaymentMethodTypeVisa:
          return BTUILocalizedString(CARD_TYPE_VISA);
    case BTUIPaymentMethodTypeJCB:
          return BTUILocalizedString(CARD_TYPE_JCB);
    case BTUIPaymentMethodTypeLaser:
          return BTUILocalizedString(CARD_TYPE_LASER);
    case BTUIPaymentMethodTypeMaestro:
          return BTUILocalizedString(CARD_TYPE_MAESTRO);
    case BTUIPaymentMethodTypeUnionPay:
          return BTUILocalizedString(CARD_TYPE_UNION_PAY);
    case BTUIPaymentMethodTypeSolo:
          return BTUILocalizedString(CARD_TYPE_SOLO);
    case BTUIPaymentMethodTypeSwitch:
          return BTUILocalizedString(CARD_TYPE_SWITCH);
    case BTUIPaymentMethodTypeUKMaestro:
          return BTUILocalizedString(CARD_TYPE_MAESTRO);
    case BTUIPaymentMethodTypePayPal:
          return BTUILocalizedString(PAYPAL_CARD_BRAND);
    case BTUIPaymentMethodTypeCoinbase:
          return BTUILocalizedString(PAYMENT_METHOD_TYPE_COINBASE);
    }
    
}

+ (void)vibrate {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

@end
