/*
 * Venmo SDK
 *
 ******************************
 * BTPaymentCardUtils.h
 ******************************
 *
 * This class does client-side credit card validation and formatting.
 * To manage the different types of credit cards, it creates a few static BTPaymentCardType objects,
 * one for each brand of card, and populates each card's data.
 */

#import "BTPaymentCardType.h"

@interface BTPaymentCardUtils : NSObject

+ (NSString *)formatNumberForComputing:(NSString *)cardNumber;
+ (NSString *)formatNumberForViewing:(NSString *)number;

+ (BTPaymentCardType *)cardTypeForNumber:(NSString *)number;
+ (BOOL)isValidNumber:(NSString *)number;

@end
