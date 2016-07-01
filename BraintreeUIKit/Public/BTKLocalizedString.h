#import <Foundation/Foundation.h>

#define BTKLocalizedString(KEY) [BTKLocalizedString KEY]

@interface BTKLocalizedString : NSObject

#pragma mark Forms and Helpers

/// Credit card number field placeholder
+ (NSString *)CARD_NUMBER_PLACEHOLDER;
/// CVV (credit card security code) field placeholder
+ (NSString *)CVV_FIELD_PLACEHOLDER;
/// Credit card expiration date field placeholder (MM/YYYY format)
+ (NSString *)EXPIRY_PLACEHOLDER_FOUR_DIGIT_YEAR;
/// Credit card expiration date field placeholder (MM/YY format)
+ (NSString *)EXPIRY_PLACEHOLDER_TWO_DIGIT_YEAR;
/// Credit card billing postal code field placeholder"
+ (NSString *)POSTAL_CODE_PLACEHOLDER;
/// OK Button on card form alert view for top level errors
+ (NSString *)TOP_LEVEL_ERROR_ALERT_VIEW_OK_BUTTON_TEXT;
/// Phone number field placeholder
+ (NSString *)PHONE_NUMBER_PLACEHOLDER;

#pragma mark Card Brands and Payment Methods

/// PayPal payment method name
+ (NSString *)PAYPAL_CARD_BRAND;
/// American Express card brand
+ (NSString *)CARD_TYPE_AMERICAN_EXPRESS;
/// Discover card brand
+ (NSString *)CARD_TYPE_DISCOVER;
/// Diners Club card brand
+ (NSString *)CARD_TYPE_DINERS_CLUB;
/// MasterCard card brand
+ (NSString *)CARD_TYPE_MASTER_CARD;
/// Visa card brand
+ (NSString *)CARD_TYPE_VISA;
/// JCB card brand
+ (NSString *)CARD_TYPE_JCB;
/// Maestro card brand
+ (NSString *)CARD_TYPE_MAESTRO;
/// UnionPay card brand
+ (NSString *)CARD_TYPE_UNION_PAY;
/// Switch card brand
+ (NSString *)CARD_TYPE_SWITCH;
/// Solo card brand
+ (NSString *)CARD_TYPE_SOLO;
/// Laser card brand
+ (NSString *)CARD_TYPE_LASER;
/// PayPal (as a standalone term, referring to the payment method type, analogous to Visa or Discover)
+ (NSString *)PAYMENT_METHOD_TYPE_PAYPAL;
/// Coinbase (as a standalone term, referring to the bitcoin wallet company)
+ (NSString *)PAYMENT_METHOD_TYPE_COINBASE;
/// Venmo (as a standalone term, referring to Venmo the company)
+ (NSString *)PAYMENT_METHOD_TYPE_VENMO;
/// Apple Pay (as a standalone term, referring to Apple Pay the product offered by Apple.)
+ (NSString *)PAYMENT_METHOD_TYPE_APPLE_PAY;

@end
