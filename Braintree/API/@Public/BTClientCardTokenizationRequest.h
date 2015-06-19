#import <Foundation/Foundation.h>

/// Representation of a card that should be uploaded to Braintree for payment method tokenization.
@interface BTClientCardTokenizationRequest : NSObject

/// The raw card number (PAN)
@property (nonatomic, copy) NSString *number;

/// The raw expiration month (M or MM, e.g. @"01")
@property (nonatomic, copy) NSString *expirationMonth;

/// The raw expiration year (YY or YYYY, e.g. @"2018")
@property (nonatomic, copy) NSString *expirationYear;

/// The raw expiration date (MM/YY or MM/YYYY, e.g. @"5/17"), mutally exclusive with expirationMonth and expirationYear
@property (nonatomic, copy) NSString *expirationDate;

/// The raw cvv three or four digit verification code (possibly required, depending on your Gateway settings)
@property (nonatomic, copy) NSString *cvv;

/// The raw postal code (possibly required, depending on your Gateway settings)
@property (nonatomic, copy) NSString *postalCode;

/// Specifies that the card details should be tokenized, rather than validated and fully created as
/// a Payment Method in the Vault.
///
/// @return NO
@property (nonatomic, readonly, assign) BOOL shouldValidate;

/// Additional card parameters. See our documentation online for information about the available fields.
@property (nonatomic, strong) NSDictionary *additionalParameters;

/// Construct a card request parameter dictionary.
///
/// @return The card request as a dictionary for uploading as parameters in API requests.
- (NSDictionary *)parameters;

@end
