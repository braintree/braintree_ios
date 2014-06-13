#import "BTUIViewUtil.h"
@import AudioToolbox;

@implementation BTUIViewUtil

+ (BTUIPaymentMethodType)paymentMethodTypeForCardType:(BTUICardType *)cardType {

    if (cardType == nil) {
        return BTUIPaymentMethodTypeUnknown;
    }

    if ([cardType.brand isEqualToString:BTUICardBrandAMEX]) {
        return BTUIPaymentMethodTypeAMEX;
    } else if ([cardType.brand isEqualToString:BTUICardBrandVisa]) {
        return BTUIPaymentMethodTypeVisa;
    } else if ([cardType.brand isEqualToString:BTUICardBrandMasterCard]) {
        return BTUIPaymentMethodTypeMasterCard;
    } else if ([cardType.brand isEqualToString:BTUICardBrandDiscover]) {
        return BTUIPaymentMethodTypeDiscover;
    } else if ([cardType.brand isEqualToString:BTUICardBrandMaestro]) {
        return BTUIPaymentMethodTypeMaestro;
    } else if ([cardType.brand isEqualToString:BTUICardBrandDinersClub]) {
        return BTUIPaymentMethodTypeDinersClub;
    } else if ([cardType.brand isEqualToString:BTUICardBrandJCB]) {
        return BTUIPaymentMethodTypeJCB;
    } else {
        return BTUIPaymentMethodTypeUnknown;
    }
}

+ (void)vibrate {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

@end
