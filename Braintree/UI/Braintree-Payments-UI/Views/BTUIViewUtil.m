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
    } else if ([cardType.brand isEqualToString:BTUILocalizedString(CARD_TYPE_DISCOVER)]) {
        return BTUIPaymentMethodTypeMaestro;
    } else if ([cardType.brand isEqualToString:BTUILocalizedString(CARD_TYPE_MAESTRO)]) {
        return BTUIPaymentMethodTypeDinersClub;
    } else if ([cardType.brand isEqualToString:BTUILocalizedString(CARD_TYPE_DINERS_CLUB)]) {
        return BTUIPaymentMethodTypeJCB;
    } else {
        return BTUIPaymentMethodTypeUnknown;
    }
}

+ (void)vibrate {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

@end
