#import <Foundation/Foundation.h>
@class BTThreeDSecurePostalAddress;

NS_ASSUME_NONNULL_BEGIN

/**
 Additional information for a 3DS lookup. Used in 3DS 2.0+ flows.
 */
@interface BTThreeDSecureAdditionalInformation : NSObject

/**
 Optional. The shipping address used for verification
 @see BTThreeDSecurePostalAddress
 */
@property (nonatomic, nullable, copy) BTThreeDSecurePostalAddress *shippingAddress;

/**
 Optional. The 2-digit string indicating the shipping method chosen for the transaction

 Possible Values:
 01 Ship to cardholder billing address
 02 Ship to another verified address on file with merchant
 03 Ship to address that is different than billing address
 04 Ship to store (store address should be populated on request)
 05 Digital goods
 06 Travel and event tickets, not shipped
 07 Other
 */
@property (nonatomic, nullable, copy) NSString *shippingMethodIndicator;

/**
 Optional. The 3-letter string representing the merchant product code

 Possible Values:
 AIR Airline
 GEN General Retail
 DIG Digital Goods
 SVC Services
 RES Restaurant
 TRA Travel
 DSP Cash Dispensing
 REN Car Rental
 GAS Fueld
 LUX Luxury Retail
 ACC Accommodation Retail
 TBD Other
 */
@property (nonatomic, nullable, copy) NSString *productCode;

/**
 Optional. The 2-digit number indicating the delivery timeframe

 Possible values:
 01 Electronic delivery
 02 Same day shipping
 03 Overnight shipping
 04 Two or more day shipping
 */
@property (nonatomic, nullable, copy) NSString *deliveryTimeframe;

/**
 Optional. For electronic delivery, email address to which the merchandise was delivered
 */
@property (nonatomic, nullable, copy) NSString *deliveryEmail;

/**
 Optional. The 2-digit number indicating whether the cardholder is reordering previously purchased merchandise

 Possible values:
 01 First time ordered
 02 Reordered
 */
@property (nonatomic, nullable, copy) NSString *reorderIndicator;

/**
 Optional. The 2-digit number indicating whether the cardholder is placing an order with a future availability or release date

 Possible values:
 01 Merchandise available
 02 Future availability
 */
@property (nonatomic, nullable, copy) NSString *preorderIndicator;

/**
 Optional. The 8-digit number (format: YYYYMMDD) indicating expected date that a pre-ordered purchase will be available
 */
@property (nonatomic, nullable, copy) NSString *preorderDate;

/**
 Optional. The purchase amount total for prepaid gift cards in major units
 */
@property (nonatomic, nullable, copy) NSString *giftCardAmount;

/**
 Optional. ISO 4217 currency code for the gift card purchased
 */
@property (nonatomic, nullable, copy) NSString *giftCardCurrencyCode;

/**
 Optional. Total count of individual prepaid gift cards purchased
 */
@property (nonatomic, nullable, copy) NSString *giftCardCount;

/**
 Optional. The 2-digit value representing the length of time cardholder has had account.

 Possible values:
 01 No account
 02 Created during transaction
 03 Less than 30 days
 04 30-60 days
 05 More than 60 days
 */
@property (nonatomic, nullable, copy) NSString *accountAgeIndicator;

/**
 Optional. The 8-digit number (format: YYYYMMDD) indicating the date the cardholder opened the account.
 */
@property (nonatomic, nullable, copy) NSString *accountCreateDate;

/**
 Optional. The 2-digit value representing the length of time since the last change to the cardholder account. This includes shipping address, new payment account or new user added.

 Possible values:
 01 Changed during transaction
 02 Less than 30 days
 03 30-60 days
 04 More than 60 days
 */
@property (nonatomic, nullable, copy) NSString *accountChangeIndicator;

/**
 Optional. The 8-digit number (format: YYYYMMDD) indicating the date the cardholder's account was last changed. This includes changes to the billing or shipping address, new payment accounts or new users added.
 */
@property (nonatomic, nullable, copy) NSString *accountChangeDate;

/**
 Optional. The 2-digit value representing the length of time since the cardholder changed or reset the password on the account.

 Possible values:
 01 No change
 02 Changed during transaction
 03 Less than 30 days
 04 30-60 days
 05 More than 60 days
 */
@property (nonatomic, nullable, copy) NSString *accountPwdChangeIndicator;

/**
 Optional. The 8-digit number (format: YYYYMMDD) indicating the date the cardholder last changed or reset password on account.
 */
@property (nonatomic, nullable, copy) NSString *accountPwdChangeDate;

/**
 Optional. The 2-digit value indicating when the shipping address used for transaction was first used.

 Possible values:
 01 This transaction
 02 Less than 30 days
 03 30-60 days
 04 More than 60 days
 */
@property (nonatomic, nullable, copy) NSString *shippingAddressUsageIndicator;

/**
 Optional. The 8-digit number (format: YYYYMMDD) indicating the date when the shipping address used for this transaction was first used.
 */
@property (nonatomic, nullable, copy) NSString *shippingAddressUsageDate;

/**
 Optional. Number of transactions (successful or abandoned) for this cardholder account within the last 24 hours.
 */
@property (nonatomic, nullable, copy) NSString *transactionCountDay;

/**
 Optional. Number of transactions (successful or abandoned) for this cardholder account within the last year.
 */
@property (nonatomic, nullable, copy) NSString *transactionCountYear;

/**
 Optional. Number of add card attempts in the last 24 hours.
 */
@property (nonatomic, nullable, copy) NSString *addCardAttempts;

/**
 Optional. Number of purchases with this cardholder account during the previous six months.
 */
@property (nonatomic, nullable, copy) NSString *accountPurchases;

/**
 Optional. The 2-digit value indicating whether the merchant experienced suspicious activity (including previous fraud) on the account.

 Possible values:
 01 No suspicious activity
 02 Suspicious activity observed
 */
@property (nonatomic, nullable, copy) NSString *fraudActivity;

/**
 Optional. The 2-digit value indicating if the cardholder name on the account is identical to the shipping name used for the transaction.

 Possible values:
 01 Account name identical to shipping name
 02 Account name different than shipping name
 */
@property (nonatomic, nullable, copy) NSString *shippingNameIndicator;

/**
 Optional. The 2-digit value indicating the length of time that the payment account was enrolled in the merchant account.

 Possible values:
 01 No account (guest checkout)
 02 During the transaction
 03 Less than 30 days
 04 30-60 days
 05 More than 60 days
 */
@property (nonatomic, nullable, copy) NSString *paymentAccountIndicator;

/**
 Optional. The 8-digit number (format: YYYYMMDD) indicating the date the payment account was added to the cardholder account.
 */
@property (nonatomic, nullable, copy) NSString *paymentAccountAge;

/**
 Optional. The 1-character value (Y/N) indicating whether cardholder billing and shipping addresses match.
 */
@property (nonatomic, nullable, copy) NSString *addressMatch;

/**
 Optional. Additional cardholder account information.
 */
@property (nonatomic, nullable, copy) NSString *accountID;

/**
 Optional. The IP address of the consumer. IPv4 and IPv6 are supported.
 */
@property (nonatomic, nullable, copy) NSString *ipAddress;

/**
 Optional. Brief description of items purchased.
 */
@property (nonatomic, nullable, copy) NSString *orderDescription;

/**
 Optional. Unformatted tax amount without any decimalization (ie. $123.67 = 12367).
 */
@property (nonatomic, nullable, copy) NSString *taxAmount;

/**
 Optional. The exact content of the HTTP user agent header.
 */
@property (nonatomic, nullable, copy) NSString *userAgent;

/**
 Optional. The 2-digit number indicating the type of authentication request.

 Possible values:
 02 Recurring transaction
 03 Installment transaction
 */
@property (nonatomic, nullable, copy) NSString *authenticationIndicator;

/**
 Optional.  An integer value greater than 1 indicating the maximum number of permitted authorizations for installment payments.
 */
@property (nonatomic, nullable, copy) NSString *installment;

/**
 Optional. The 14-digit number (format: YYYYMMDDHHMMSS) indicating the date in UTC of original purchase.
 */
@property (nonatomic, nullable, copy) NSString *purchaseDate;

/**
 Optional. The 8-digit number (format: YYYYMMDD) indicating the date after which no further recurring authorizations should be performed.
 */
@property (nonatomic, nullable, copy) NSString *recurringEnd;

/**
 Optional. Integer value indicating the minimum number of days between recurring authorizations. A frequency of monthly is indicated by the value 28. Multiple of 28 days will be used to indicate months (ex. 6 months = 168).
 */
@property (nonatomic, nullable, copy) NSString *recurringFrequency;

/**
 Optional. The 2-digit number of minutes (minimum 05) to set the maximum amount of time for all 3DS 2.0 messages to be communicated between all components.
 */
@property (nonatomic, nullable, copy) NSString *sdkMaxTimeout;

/**
 Optional. The work phone number used for verification. Only numbers; remove dashes, parenthesis and other characters.
 */
@property (nonatomic, nullable, copy) NSString *workPhoneNumber;

@end

NS_ASSUME_NONNULL_END
