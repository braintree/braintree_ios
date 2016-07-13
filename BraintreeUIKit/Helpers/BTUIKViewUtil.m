#import "BTUIKViewUtil.h"
#import "BTUIKMasterCardVectorArtView.h"
#import "BTUIKJCBVectorArtView.h"
#import "BTUIKMaestroVectorArtView.h"
#import "BTUIKVisaVectorArtView.h"
#import "BTUIKDiscoverVectorArtView.h"
#import "BTUIKUnknownCardVectorArtView.h"
#import "BTUIKDinersClubVectorArtView.h"
#import "BTUIKAmExVectorArtView.h"
#import "BTUIKPayPalMonogramCardView.h"
#import "BTUIKCoinbaseMonogramCardView.h"
#import "BTUIKVenmoMonogramCardView.h"
#import "BTUIKUnionPayVectorArtView.h"
#import "BTUIKApplePayMarkVectorArtView.h"

@import AudioToolbox;

@implementation BTUIKViewUtil

+ (BTUIKPaymentOptionType)paymentMethodTypeForCardType:(BTUIKCardType *)cardType {

    if (cardType == nil) {
        return BTUIKPaymentOptionTypeUnknown;
    }

    if ([cardType.brand isEqualToString:BTUIKLocalizedString(CARD_TYPE_AMERICAN_EXPRESS)]) {
        return BTUIKPaymentOptionTypeAMEX;
    } else if ([cardType.brand isEqualToString:BTUIKLocalizedString(CARD_TYPE_VISA)]) {
        return BTUIKPaymentOptionTypeVisa;
    } else if ([cardType.brand isEqualToString:BTUIKLocalizedString(CARD_TYPE_MASTER_CARD)]) {
        return BTUIKPaymentOptionTypeMasterCard;
    } else if ([cardType.brand isEqualToString:BTUIKLocalizedString(CARD_TYPE_DISCOVER)]) {
        return BTUIKPaymentOptionTypeDiscover;
    } else if ([cardType.brand isEqualToString:BTUIKLocalizedString(CARD_TYPE_JCB)]) {
        return BTUIKPaymentOptionTypeJCB;
    } else if ([cardType.brand isEqualToString:BTUIKLocalizedString(CARD_TYPE_MAESTRO)]) {
        return BTUIKPaymentOptionTypeMaestro;
    } else if ([cardType.brand isEqualToString:BTUIKLocalizedString(CARD_TYPE_DINERS_CLUB)]) {
        return BTUIKPaymentOptionTypeDinersClub;
    } else if ([cardType.brand isEqualToString:BTUIKLocalizedString(CARD_TYPE_UNION_PAY)]) {
        return BTUIKPaymentOptionTypeUnionPay;
    } else {
        return BTUIKPaymentOptionTypeUnknown;
    }
}

+ (NSString *)nameForPaymentMethodType:(BTUIKPaymentOptionType)paymentMethodType {
  switch (paymentMethodType) {
    case BTUIKPaymentOptionTypeUnknown:
      return @"Card";
    case BTUIKPaymentOptionTypeAMEX:
          return BTUIKLocalizedString(CARD_TYPE_AMERICAN_EXPRESS);
    case BTUIKPaymentOptionTypeDinersClub:
          return BTUIKLocalizedString(CARD_TYPE_DINERS_CLUB);
    case BTUIKPaymentOptionTypeDiscover:
      return BTUIKLocalizedString(CARD_TYPE_DISCOVER);
    case BTUIKPaymentOptionTypeMasterCard:
        return BTUIKLocalizedString(CARD_TYPE_MASTER_CARD);
    case BTUIKPaymentOptionTypeVisa:
          return BTUIKLocalizedString(CARD_TYPE_VISA);
    case BTUIKPaymentOptionTypeJCB:
          return BTUIKLocalizedString(CARD_TYPE_JCB);
    case BTUIKPaymentOptionTypeLaser:
          return BTUIKLocalizedString(CARD_TYPE_LASER);
    case BTUIKPaymentOptionTypeMaestro:
          return BTUIKLocalizedString(CARD_TYPE_MAESTRO);
    case BTUIKPaymentOptionTypeUnionPay:
          return BTUIKLocalizedString(CARD_TYPE_UNION_PAY);
    case BTUIKPaymentOptionTypeSolo:
          return BTUIKLocalizedString(CARD_TYPE_SOLO);
    case BTUIKPaymentOptionTypeSwitch:
          return BTUIKLocalizedString(CARD_TYPE_SWITCH);
    case BTUIKPaymentOptionTypeUKMaestro:
          return BTUIKLocalizedString(CARD_TYPE_MAESTRO);
    case BTUIKPaymentOptionTypePayPal:
          return BTUIKLocalizedString(PAYPAL_CARD_BRAND);
    case BTUIKPaymentOptionTypeCoinbase:
          return BTUIKLocalizedString(PAYMENT_METHOD_TYPE_COINBASE);
    case BTUIKPaymentOptionTypeVenmo:
          return BTUIKLocalizedString(PAYMENT_METHOD_TYPE_VENMO);
    case BTUIKPaymentOptionTypeApplePay:
        return BTUIKLocalizedString(PAYMENT_METHOD_TYPE_APPLE_PAY);
    }
}

+ (void)vibrate {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

#pragma mark Icons

+ (BTUIKPaymentOptionType)paymentOptionTypeForPaymentInfoType:(NSString *)typeString {
    if ([typeString isEqualToString:@"Visa"]) {
        return BTUIKPaymentOptionTypeVisa;
    } else if ([typeString isEqualToString:@"MasterCard"]) {
        return BTUIKPaymentOptionTypeMasterCard;
    } else if ([typeString isEqualToString:@"Coinbase"]) {
        return BTUIKPaymentOptionTypeCoinbase;
    } else if ([typeString isEqualToString:@"PayPal"]) {
        return BTUIKPaymentOptionTypePayPal;
    } else if ([typeString isEqualToString:@"DinersClub"]) {
        return BTUIKPaymentOptionTypeDinersClub;
    } else if ([typeString isEqualToString:@"JCB"]) {
        return BTUIKPaymentOptionTypeJCB;
    } else if ([typeString isEqualToString:@"Maestro"]) {
        return BTUIKPaymentOptionTypeMaestro;
    } else if ([typeString isEqualToString:@"Discover"]) {
        return BTUIKPaymentOptionTypeDiscover;
    } else if ([typeString isEqualToString:@"UKMaestro"]) {
        return BTUIKPaymentOptionTypeUKMaestro;
    } else if ([typeString isEqualToString:@"AMEX"]) {
        return BTUIKPaymentOptionTypeAMEX;
    } else if ([typeString isEqualToString:@"Solo"]) {
        return BTUIKPaymentOptionTypeSolo;
    } else if ([typeString isEqualToString:@"Laser"]) {
        return BTUIKPaymentOptionTypeLaser;
    } else if ([typeString isEqualToString:@"Switch"]) {
        return BTUIKPaymentOptionTypeSwitch;
    } else if ([typeString isEqualToString:@"UnionPay"]) {
        return BTUIKPaymentOptionTypeUnionPay;
    } else if ([typeString isEqualToString:@"Venmo"]) {
        return BTUIKPaymentOptionTypeVenmo;
    } else if ([typeString isEqualToString:@"ApplePay"]) {
        return BTUIKPaymentOptionTypeApplePay;
    } else {
        return BTUIKPaymentOptionTypeUnknown;
    }
}

+ (BTUIKVectorArtView *)vectorArtViewForPaymentInfoType:(NSString *)typeString {
    return [self vectorArtViewForPaymentOptionType:[self.class paymentOptionTypeForPaymentInfoType:typeString]];
}

+ (BTUIKVectorArtView *)vectorArtViewForPaymentOptionType:(BTUIKPaymentOptionType)type {
    switch (type) {
        case BTUIKPaymentOptionTypeVisa:
            return [BTUIKVisaVectorArtView new];
        case BTUIKPaymentOptionTypeMasterCard:
            return [BTUIKMasterCardVectorArtView new];
        case BTUIKPaymentOptionTypeCoinbase:
            return [BTUIKCoinbaseMonogramCardView new];
        case BTUIKPaymentOptionTypePayPal:
            return [BTUIKPayPalMonogramCardView new];
        case BTUIKPaymentOptionTypeDinersClub:
            return [BTUIKDinersClubVectorArtView new];
        case BTUIKPaymentOptionTypeJCB:
            return [BTUIKJCBVectorArtView new];
        case BTUIKPaymentOptionTypeMaestro:
            return [BTUIKMaestroVectorArtView new];
        case BTUIKPaymentOptionTypeDiscover:
            return [BTUIKDiscoverVectorArtView new];
        case BTUIKPaymentOptionTypeUKMaestro:
            return [BTUIKMaestroVectorArtView new];
        case BTUIKPaymentOptionTypeAMEX:
            return [BTUIKAmExVectorArtView new];
        case BTUIKPaymentOptionTypeVenmo:
            return [BTUIKVenmoMonogramCardView new];
        case BTUIKPaymentOptionTypeUnionPay:
            return [BTUIKUnionPayVectorArtView new];
        case BTUIKPaymentOptionTypeApplePay:
            return [BTUIKApplePayMarkVectorArtView new];
        case BTUIKPaymentOptionTypeSolo:
        case BTUIKPaymentOptionTypeLaser:
        case BTUIKPaymentOptionTypeSwitch:
        case BTUIKPaymentOptionTypeUnknown:
            return [BTUIKUnknownCardVectorArtView new];
    }
}

+ (BOOL)isLanguageLayoutDirectionRightToLeft
{
    return [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

+ (NSTextAlignment)naturalTextAlignment
{
    return [self isLanguageLayoutDirectionRightToLeft] ? NSTextAlignmentRight : NSTextAlignmentLeft;
}

+ (NSTextAlignment)naturalTextAlignmentInverse
{
    return [self isLanguageLayoutDirectionRightToLeft] ? NSTextAlignmentLeft : NSTextAlignmentRight;
}

@end
