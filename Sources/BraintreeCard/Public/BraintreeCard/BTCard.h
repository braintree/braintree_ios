#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The card tokenization request represents raw credit or debit card data provided by the customer. Its main purpose is to serve as the input for tokenization.
*/
@interface BTCard : NSObject

/**
 The card number
*/
@property (nonatomic, nullable, copy) NSString *number;

/**
 The expiration month as a one or two-digit number on the Gregorian calendar
*/
@property (nonatomic, nullable, copy) NSString *expirationMonth;

/**
 The expiration year as a two or four-digit number on the Gregorian calendar
*/
@property (nonatomic, nullable, copy) NSString *expirationYear;

/**
 The card verification code (like CVV or CID).

 @note If you wish to create a CVV-only payment method nonce to verify a card already stored in your Vault, omit all other properties to only collect CVV.
*/
@property (nonatomic, nullable, copy) NSString *cvv;

/**
 The postal code associated with the card's billing address
*/

@property (nonatomic, nullable, copy) NSString *postalCode;

/**
 Optional: the cardholder's name.
*/
@property (nonatomic, nullable, copy) NSString *cardholderName;

/**
 Optional: first name on the card.
 */
@property (nonatomic, nullable, copy) NSString *firstName;

/**
 Optional: last name on the card.
 */
@property (nonatomic, nullable, copy) NSString *lastName;

/**
 Optional: company name associated with the card.
 */
@property (nonatomic, nullable, copy) NSString *company;

/**
 Optional: the street address associated with the card's billing address
*/
@property (nonatomic, nullable, copy) NSString *streetAddress;

/**
 Optional: the extended address associated with the card's billing address
 */
@property (nonatomic, nullable, copy) NSString *extendedAddress;

/**
 Optional: the city associated with the card's billing address
*/
@property (nonatomic, nullable, copy) NSString *locality;

/**
 Optional: Either a two-letter state code (for the US), or an ISO-3166-2 country subdivision code of up to three letters.
*/
@property (nonatomic, nullable, copy) NSString *region;

/**
 Optional: the country name associated with the card's billing address.

 @note Braintree only accepts specific country names.
 @see https://developer.paypal.com/braintree/docs/reference/general/countries#list-of-countries
*/
@property (nonatomic, nullable, copy) NSString *countryName;

/**
 Optional: the ISO 3166-1 alpha-2 country code specified in the card's billing address.

 @note Braintree only accepts specific alpha-2 values.
 @see https://developer.paypal.com/braintree/docs/reference/general/countries#list-of-countries
*/
@property (nonatomic, nullable, copy) NSString *countryCodeAlpha2;

/**
 Optional: The ISO 3166-1 alpha-3 country code specified in the card's billing address.

 @note Braintree only accepts specific alpha-3 values.
 @see https://developer.paypal.com/braintree/docs/reference/general/countries#list-of-countries
 */
@property (nonatomic, nullable, copy) NSString *countryCodeAlpha3;

/**
 Optional: The ISO 3166-1 numeric country code specified in the card's billing address.

 @note Braintree only accepts specific numeric values.
 @see https://developer.paypal.com/braintree/docs/reference/general/countries#list-of-countries
 */
@property (nonatomic, nullable, copy) NSString *countryCodeNumeric;

/**
 Controls whether or not to return validations and/or verification results. By default, this is not enabled.

 @note Use this flag with caution. By enabling client-side validation, certain tokenize card requests may result in adding the card to the vault. These semantics are not currently documented.
*/
@property (nonatomic, assign) BOOL shouldValidate;

/**
 Optional: If authentication insight is requested. If this property is set to true, a `merchantAccountID` must be provided. Defaults to false.
 */
@property (nonatomic, assign) BOOL authenticationInsightRequested;

/**
 Optional: The merchant account ID.
 */
@property (nonatomic, nullable, copy) NSString *merchantAccountID;

@end

NS_ASSUME_NONNULL_END
