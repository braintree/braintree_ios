#import "BTKViewUtil.h"
#import "BTKMasterCardVectorArtView.h"
#import "BTKJCBVectorArtView.h"
#import "BTKMaestroVectorArtView.h"
#import "BTKVisaVectorArtView.h"
#import "BTKDiscoverVectorArtView.h"
#import "BTKUnknownCardVectorArtView.h"
#import "BTKDinersClubVectorArtView.h"
#import "BTKAmExVectorArtView.h"
#import "BTKPayPalMonogramCardView.h"
#import "BTKCoinbaseMonogramCardView.h"
#import "BTKVenmoMonogramCardView.h"
#import "BTKUnionPayVectorArtView.h"
#import "BTKApplePayMarkVectorArtView.h"

@import AudioToolbox;

@implementation BTKViewUtil

+ (BTKPaymentOptionType)paymentMethodTypeForCardType:(BTKCardType *)cardType {

    if (cardType == nil) {
        return BTKPaymentOptionTypeUnknown;
    }

    if ([cardType.brand isEqualToString:BTKLocalizedString(CARD_TYPE_AMERICAN_EXPRESS)]) {
        return BTKPaymentOptionTypeAMEX;
    } else if ([cardType.brand isEqualToString:BTKLocalizedString(CARD_TYPE_VISA)]) {
        return BTKPaymentOptionTypeVisa;
    } else if ([cardType.brand isEqualToString:BTKLocalizedString(CARD_TYPE_MASTER_CARD)]) {
        return BTKPaymentOptionTypeMasterCard;
    } else if ([cardType.brand isEqualToString:BTKLocalizedString(CARD_TYPE_DISCOVER)]) {
        return BTKPaymentOptionTypeDiscover;
    } else if ([cardType.brand isEqualToString:BTKLocalizedString(CARD_TYPE_JCB)]) {
        return BTKPaymentOptionTypeJCB;
    } else if ([cardType.brand isEqualToString:BTKLocalizedString(CARD_TYPE_MAESTRO)]) {
        return BTKPaymentOptionTypeMaestro;
    } else if ([cardType.brand isEqualToString:BTKLocalizedString(CARD_TYPE_DINERS_CLUB)]) {
        return BTKPaymentOptionTypeDinersClub;
    } else if ([cardType.brand isEqualToString:BTKLocalizedString(CARD_TYPE_UNION_PAY)]) {
        return BTKPaymentOptionTypeUnionPay;
    } else {
        return BTKPaymentOptionTypeUnknown;
    }
}

+ (NSString *)nameForPaymentMethodType:(BTKPaymentOptionType)paymentMethodType {
  switch (paymentMethodType) {
    case BTKPaymentOptionTypeUnknown:
      return @"Card";
    case BTKPaymentOptionTypeAMEX:
          return BTKLocalizedString(CARD_TYPE_AMERICAN_EXPRESS);
    case BTKPaymentOptionTypeDinersClub:
          return BTKLocalizedString(CARD_TYPE_DINERS_CLUB);
    case BTKPaymentOptionTypeDiscover:
      return BTKLocalizedString(CARD_TYPE_DISCOVER);
    case BTKPaymentOptionTypeMasterCard:
        return BTKLocalizedString(CARD_TYPE_MASTER_CARD);
    case BTKPaymentOptionTypeVisa:
          return BTKLocalizedString(CARD_TYPE_VISA);
    case BTKPaymentOptionTypeJCB:
          return BTKLocalizedString(CARD_TYPE_JCB);
    case BTKPaymentOptionTypeLaser:
          return BTKLocalizedString(CARD_TYPE_LASER);
    case BTKPaymentOptionTypeMaestro:
          return BTKLocalizedString(CARD_TYPE_MAESTRO);
    case BTKPaymentOptionTypeUnionPay:
          return BTKLocalizedString(CARD_TYPE_UNION_PAY);
    case BTKPaymentOptionTypeSolo:
          return BTKLocalizedString(CARD_TYPE_SOLO);
    case BTKPaymentOptionTypeSwitch:
          return BTKLocalizedString(CARD_TYPE_SWITCH);
    case BTKPaymentOptionTypeUKMaestro:
          return BTKLocalizedString(CARD_TYPE_MAESTRO);
    case BTKPaymentOptionTypePayPal:
          return BTKLocalizedString(PAYPAL_CARD_BRAND);
    case BTKPaymentOptionTypeCoinbase:
          return BTKLocalizedString(PAYMENT_METHOD_TYPE_COINBASE);
    case BTKPaymentOptionTypeVenmo:
          return BTKLocalizedString(PAYMENT_METHOD_TYPE_VENMO);
    case BTKPaymentOptionTypeApplePay:
        return BTKLocalizedString(PAYMENT_METHOD_TYPE_APPLE_PAY);
    }
}

+ (void)vibrate {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

#pragma mark Icons

+ (BTKPaymentOptionType)paymentOptionTypeForPaymentInfoType:(NSString *)typeString {
    if ([typeString isEqualToString:@"Visa"]) {
        return BTKPaymentOptionTypeVisa;
    } else if ([typeString isEqualToString:@"MasterCard"]) {
        return BTKPaymentOptionTypeMasterCard;
    } else if ([typeString isEqualToString:@"Coinbase"]) {
        return BTKPaymentOptionTypeCoinbase;
    } else if ([typeString isEqualToString:@"PayPal"]) {
        return BTKPaymentOptionTypePayPal;
    } else if ([typeString isEqualToString:@"DinersClub"]) {
        return BTKPaymentOptionTypeDinersClub;
    } else if ([typeString isEqualToString:@"JCB"]) {
        return BTKPaymentOptionTypeJCB;
    } else if ([typeString isEqualToString:@"Maestro"]) {
        return BTKPaymentOptionTypeMaestro;
    } else if ([typeString isEqualToString:@"Discover"]) {
        return BTKPaymentOptionTypeDiscover;
    } else if ([typeString isEqualToString:@"UKMaestro"]) {
        return BTKPaymentOptionTypeUKMaestro;
    } else if ([typeString isEqualToString:@"AMEX"]) {
        return BTKPaymentOptionTypeAMEX;
    } else if ([typeString isEqualToString:@"Solo"]) {
        return BTKPaymentOptionTypeSolo;
    } else if ([typeString isEqualToString:@"Laser"]) {
        return BTKPaymentOptionTypeLaser;
    } else if ([typeString isEqualToString:@"Switch"]) {
        return BTKPaymentOptionTypeSwitch;
    } else if ([typeString isEqualToString:@"UnionPay"]) {
        return BTKPaymentOptionTypeUnionPay;
    } else if ([typeString isEqualToString:@"Venmo"]) {
        return BTKPaymentOptionTypeVenmo;
    } else if ([typeString isEqualToString:@"ApplePay"]) {
        return BTKPaymentOptionTypeApplePay;
    } else {
        return BTKPaymentOptionTypeUnknown;
    }
}

+ (BTKVectorArtView *)vectorArtViewForPaymentInfoType:(NSString *)typeString {
    return [self vectorArtViewForPaymentOptionType:[self.class paymentOptionTypeForPaymentInfoType:typeString]];
}

+ (BTKVectorArtView *)vectorArtViewForPaymentOptionType:(BTKPaymentOptionType)type {
    switch (type) {
        case BTKPaymentOptionTypeVisa:
            return [BTKVisaVectorArtView new];
        case BTKPaymentOptionTypeMasterCard:
            return [BTKMasterCardVectorArtView new];
        case BTKPaymentOptionTypeCoinbase:
            return [BTKCoinbaseMonogramCardView new];
        case BTKPaymentOptionTypePayPal:
            return [BTKPayPalMonogramCardView new];
        case BTKPaymentOptionTypeDinersClub:
            return [BTKDinersClubVectorArtView new];
        case BTKPaymentOptionTypeJCB:
            return [BTKJCBVectorArtView new];
        case BTKPaymentOptionTypeMaestro:
            return [BTKMaestroVectorArtView new];
        case BTKPaymentOptionTypeDiscover:
            return [BTKDiscoverVectorArtView new];
        case BTKPaymentOptionTypeUKMaestro:
            return [BTKMaestroVectorArtView new];
        case BTKPaymentOptionTypeAMEX:
            return [BTKAmExVectorArtView new];
        case BTKPaymentOptionTypeVenmo:
            return [BTKVenmoMonogramCardView new];
        case BTKPaymentOptionTypeUnionPay:
            return [BTKUnionPayVectorArtView new];
        case BTKPaymentOptionTypeApplePay:
            return [BTKApplePayMarkVectorArtView new];
        case BTKPaymentOptionTypeSolo:
        case BTKPaymentOptionTypeLaser:
        case BTKPaymentOptionTypeSwitch:
        case BTKPaymentOptionTypeUnknown:
            return [BTKUnknownCardVectorArtView new];
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
