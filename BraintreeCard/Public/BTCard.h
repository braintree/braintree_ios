#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The card tokenization request represents raw credit or debit card data provided by the customer.
/// Its main purpose is to serve as the input for tokenization.
@interface BTCard : NSObject

/// A convenience initializer for creating a card tokenization request.
- (instancetype)initWithNumber:(NSString *)number
               expirationMonth:(NSString *)expirationMonth
                expirationYear:(NSString *)expirationYear
                           cvv:(nullable NSString *)cvv;

- (instancetype)initWithParameters:(NSDictionary *)parameters NS_DESIGNATED_INITIALIZER;

/// The card number
@property (nonatomic, nullable, copy) NSString *number;
/// The expiration month as a one or two-digit number on the Gregorian calendar
@property (nonatomic, nullable, copy) NSString *expirationMonth;
/// The expiration year as a two or four-digit number on the Gregorian calendar
@property (nonatomic, nullable, copy) NSString *expirationYear;
/// The card CVV
@property (nonatomic, nullable, copy) NSString *cvv;
/// The postal code associated with the card's billing address
@property (nonatomic, nullable, copy) NSString *postalCode;

/// Controls whether or not to return validations and/or verification results. By default, this is
/// not enabled.
///
/// @warning Use this flag with caution. By enabling client-side validation, certain tokenize card
/// requests may result in adding the card to the vault. These semantics are not currently documented.
@property (nonatomic, assign) BOOL shouldValidate;

@end

NS_ASSUME_NONNULL_END
