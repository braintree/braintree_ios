@import Foundation;

/// Representation of a card that should be uploaded to Braintree for payment method creation.
@interface BTClientCardRequest : NSObject

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

/// Whether or not to return validations and/or verification results to the client
///
/// This property may only have the values nil, @YES or @NO.
///
/// @warning Use this flag with caution. By enabling client-side validation, certain save card requests
///          may result in adding the payment method to the Vault. These semantics are not currently
///          documented.
@property (nonatomic, strong) NSNumber *shouldValidate;

/// Additional card parameters. See our documentation online for information about the available fields.
@property (nonatomic, strong) NSDictionary *additionalParameters;

/// Construct a card request parameter dictionary.
///
/// @return The card request as a dictionary for uploading as parameters in API requests.
- (NSDictionary *)parameters;

@end
