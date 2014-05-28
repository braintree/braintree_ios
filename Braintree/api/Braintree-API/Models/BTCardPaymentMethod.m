#import "BTCardPaymentMethod_Mutable.h"

@implementation BTCardPaymentMethod

- (NSString *)typeString {
    switch(self.type) {
        case BTCardTypeAMEX:
            return @"American Express";
        case BTCardTypeUnionPay:
            return @"China UnionPay";
        case BTCardTypeDinersClub:
            return @"Diners Club";
        case BTCardTypeDiscover:
            return @"Discover";
        case BTCardTypeJCB:
            return @"JCB";
        case BTCardTypeMaestro:
            return @"Maestro";
        case BTCardTypeMasterCard:
            return @"MasterCard";
        case BTCardTypeSolo:
            return @"Solo";
        case BTCardTypeSwitch:
            return @"Switch";
        case BTCardTypeUKMaestro:
            return @"UK Maestro";
        case BTCardTypeLaser:
            return @"Laser";
        case BTCardTypeVisa:
            return @"Visa";
        default:
            return @"Card";
    }
}

- (void)setTypeString:(NSString *)typeString {
    NSString *lowercaseTypeString = [typeString lowercaseString];

    if ([lowercaseTypeString isEqual:@"american express"]) {
        self.type = BTCardTypeAMEX;
    } else if ([lowercaseTypeString isEqual:@"diners club"]) {
        self.type = BTCardTypeDinersClub;
    } else if ([lowercaseTypeString isEqual:@"china unionpay"]) {
        self.type = BTCardTypeUnionPay;
    } else if ([lowercaseTypeString isEqual:@"discover"]) {
        self.type = BTCardTypeDiscover;
    } else if ([lowercaseTypeString isEqual:@"jcb"]) {
        self.type = BTCardTypeJCB;
    } else if ([lowercaseTypeString isEqual:@"maestro"]) {
        self.type = BTCardTypeMaestro;
    } else if ([lowercaseTypeString isEqual:@"mastercard"]) {
        self.type = BTCardTypeMasterCard;
    } else if ([lowercaseTypeString isEqual:@"solo"]) {
        self.type = BTCardTypeSolo;
    } else if ([lowercaseTypeString isEqual:@"switch"]) {
        self.type = BTCardTypeSwitch;
    } else if ([lowercaseTypeString isEqual:@"uk maestro"]) {
        self.type = BTCardTypeUKMaestro;
    } else if ([lowercaseTypeString isEqual:@"visa"]) {
        self.type = BTCardTypeVisa;
    } else {
        self.type = BTCardTypeUnknown;
    }
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p type:%@ \"%@\" nonce:%@>", NSStringFromClass([self class]), self, self.typeString, [self description], self.nonce];
}

@end
