#import "BTPaymentCardUtils.h"

static BTPaymentCardType *amex;
static BTPaymentCardType *dinersClub;
static BTPaymentCardType *discover;
static BTPaymentCardType *jcb;
static BTPaymentCardType *laser;
static BTPaymentCardType *maestro;
static BTPaymentCardType *mastercard;
static BTPaymentCardType *unionPay;
static BTPaymentCardType *visa;

static NSArray *allCardTypes;

@implementation BTPaymentCardUtils

+ (void)initialize {
	if(self == [BTPaymentCardUtils class]) {
        NSError *error;
        NSArray *defaultSpaceIndices = [NSArray arrayWithObjects:@4, @5, @10, @11, @16, @17, nil];

        // US brands
        amex = [[BTPaymentCardType alloc] init];
        amex.brand = BTCardBrandAMEX;
        amex.frontImageName = @"BTAmex";
        amex.backImageName = @"BTAmexCVV";
        amex.cardRegexPattern = @"^3[47]";
        amex.cardRegex = [NSRegularExpression regularExpressionWithPattern:amex.cardRegexPattern options:0 error:&error];
        amex.validCardLengths = [NSArray arrayWithObjects:@15, nil];
        amex.maxCardLength    = @15;
        amex.cvvLength        = @4;
        amex.prettyFormatSpaceIndices = [NSArray arrayWithObjects:@4, @5, @12, @13, nil];

        dinersClub = [[BTPaymentCardType alloc] init];
        dinersClub.brand = BTCardBrandDinersClub;
        dinersClub.frontImageName = @"BTDinersClub";
        dinersClub.cardRegexPattern = @"^(36|38|30[0-5])";
        dinersClub.cardRegex = [NSRegularExpression regularExpressionWithPattern:dinersClub.cardRegexPattern options:0 error:&error];
        dinersClub.validCardLengths = [NSArray arrayWithObjects:@14, nil];
        dinersClub.maxCardLength    = @14;
        dinersClub.cvvLength        = @3;
        dinersClub.prettyFormatSpaceIndices = [NSArray arrayWithArray:defaultSpaceIndices];

        discover = [[BTPaymentCardType alloc] init];
        discover.brand = BTCardBrandDiscover;
        discover.frontImageName = @"BTDiscover";
        discover.cardRegexPattern = @"^(6011|65|64[4-9]|622)";
        discover.cardRegex = [NSRegularExpression regularExpressionWithPattern:discover.cardRegexPattern options:0 error:&error];
        discover.validCardLengths = [NSArray arrayWithObjects:@16, nil];
        discover.maxCardLength    = @16;
        discover.cvvLength        = @3;
        discover.prettyFormatSpaceIndices = [NSArray arrayWithArray:defaultSpaceIndices];

        mastercard = [[BTPaymentCardType alloc] init];
        mastercard.brand = BTCardBrandMasterCard;
        mastercard.frontImageName = @"BTMastercard";
        mastercard.cardRegexPattern = @"^5[1-5]";
        mastercard.cardRegex = [NSRegularExpression regularExpressionWithPattern:mastercard.cardRegexPattern options:0 error:&error];
        mastercard.validCardLengths = [NSArray arrayWithObjects:@16, nil];
        mastercard.maxCardLength    = @16;
        mastercard.cvvLength        = @3;
        mastercard.prettyFormatSpaceIndices = [NSArray arrayWithArray:defaultSpaceIndices];

        visa = [[BTPaymentCardType alloc] init];
        visa.brand = BTCardBrandVisa;
        visa.frontImageName = @"BTVisa";
        visa.cardRegexPattern = @"^4";
        visa.cardRegex = [NSRegularExpression regularExpressionWithPattern:visa.cardRegexPattern options:0 error:&error];
        visa.validCardLengths = [NSArray arrayWithObjects:@16, nil];
        visa.maxCardLength    = @16;
        visa.cvvLength        = @3;
        visa.prettyFormatSpaceIndices = [NSArray arrayWithArray:defaultSpaceIndices];

        // non US brands
        jcb = [[BTPaymentCardType alloc] init];
        jcb.brand = BTCardBrandJCB;
        jcb.frontImageName = @"BTJCB";
        jcb.cardRegexPattern = @"^35";
        jcb.cardRegex = [NSRegularExpression regularExpressionWithPattern:jcb.cardRegexPattern options:0 error:&error];
        jcb.validCardLengths = [NSArray arrayWithObjects:@16, nil];
        jcb.maxCardLength    = @16;
        jcb.cvvLength        = @3;
        jcb.prettyFormatSpaceIndices = [NSArray arrayWithArray:defaultSpaceIndices];

        laser = [[BTPaymentCardType alloc] init];
        laser.brand = BTCardBrandLaser;
        laser.cardRegexPattern = @"^(6706|6771|6709)";
        laser.cardRegex = [NSRegularExpression regularExpressionWithPattern:laser.cardRegexPattern options:0 error:&error];
        laser.validCardLengths = [NSArray arrayWithObjects:@16, @17, @18, @19, nil];
        laser.maxCardLength    = @19;
        laser.cvvLength        = @3;
        laser.prettyFormatSpaceIndices = [NSArray arrayWithArray:defaultSpaceIndices];

        maestro = [[BTPaymentCardType alloc] init];
        maestro.brand = BTCardBrandMaestro;
        maestro.cardRegexPattern = @"^(5018|5020|5038|6304|6759|676[1-3])";
        maestro.cardRegex = [NSRegularExpression regularExpressionWithPattern:maestro.cardRegexPattern options:0 error:&error];
        maestro.validCardLengths = [NSArray arrayWithObjects:@12, @13, @14, @15, @16, @17, @18, @19, nil];
        maestro.maxCardLength    = @19;
        maestro.cvvLength        = @3;
        maestro.prettyFormatSpaceIndices = [NSArray arrayWithArray:defaultSpaceIndices];
        
        unionPay = [[BTPaymentCardType alloc] init];
        unionPay.brand = BTCardBrandUnionPay;
        unionPay.cardRegexPattern = @"^62";
        unionPay.cardRegex = [NSRegularExpression regularExpressionWithPattern:unionPay.cardRegexPattern options:0 error:&error];
        unionPay.validCardLengths = [NSArray arrayWithObjects:@16, @17, @18, @19, nil];
        unionPay.maxCardLength    = @19;
        unionPay.cvvLength        = @3;
        unionPay.prettyFormatSpaceIndices = [NSArray arrayWithArray:defaultSpaceIndices];

        // somewhat arbitrary order by most common credit card
        allCardTypes = [NSArray arrayWithObjects:visa, mastercard, discover, amex, dinersClub,
                        jcb, laser, maestro, unionPay, nil];
	}
}

+ (NSString *)formatNumberForComputing:(NSString *)cardNumber {
    return [cardNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSString *)formatNumberForViewing:(NSString *)number {
    // TODO: strip the number of white spaces
    number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
    BTPaymentCardType *cardType = [self cardTypeForNumber:number];
    if (cardType) {
        for (NSNumber *spaceIndex in cardType.prettyFormatSpaceIndices) {
            NSInteger spaceIndexInteger = [spaceIndex integerValue];
            if (number.length >= spaceIndexInteger) {
                // First part of the string + white space + last part of the string
                number = [NSString stringWithFormat:@"%@ %@",
                          [number substringToIndex:spaceIndexInteger],
                          [number substringWithRange:NSMakeRange(spaceIndexInteger, number.length - spaceIndexInteger)]];
            }
        }
    }
    return number;
}

+ (BTPaymentCardType *)cardTypeForNumber:(NSString *)number {
    if (!number.length) {
        return nil;
    }

    number = [self formatNumberForComputing:number];
    for (BTPaymentCardType *cardType in allCardTypes) {
        // If the card number matches a type's regex, then  return that card.
        if ([cardType.cardRegex numberOfMatchesInString:number options:0 range:NSMakeRange(0, number.length)] == 1) {
            return cardType;
        }
    }
    return nil;
}


+ (BOOL)isValidNumber:(NSString *)number {
    // A number is valid if it:
    // 1. has a card type
    // 2. is of the correct length
    // 3. passes the Luhn test
    number = [self formatNumberForComputing:number];
    BTPaymentCardType *cardType = [self cardTypeForNumber:number];
    if (cardType &&
        [cardType.validCardLengths containsObject:[NSNumber numberWithInteger:number.length]] &&
        [self isLuhnValid:number]) {
        return YES;
    }
    return NO;
}

// Luhn algoirthm for simple card number verification
// http://rosettacode.org/wiki/Luhn_test_of_credit_card_numbers#Objective-C
+ (BOOL)isLuhnValid:(NSString *)cardNumber {
	NSMutableArray *stringAsChars = [self convertStringToCharArray:cardNumber];
	BOOL isOdd = YES;
	NSInteger oddSum = 0;
	NSInteger evenSum = 0;

	for (NSInteger i = [cardNumber length] - 1; i >= 0; i--) {
		NSInteger digit = [(NSString *)[stringAsChars objectAtIndex:i] intValue];
		if (isOdd) {
			oddSum += digit;
        } else {
			evenSum += digit/5 + (2*digit) % 10;
        }

		isOdd = !isOdd;
	}

	return ((oddSum + evenSum) % 10 == 0);
}

+ (NSMutableArray *)convertStringToCharArray:(NSString *)string {
	NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[string length]];
	for (int i=0; i < [string length]; i++) {
		NSString *ichar  = [NSString stringWithFormat:@"%c", [string characterAtIndex:i]];
		[characters addObject:ichar];
	}

	return characters;
}

@end
