#import <Foundation/Foundation.h>
#import "BTCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTCardTokenizationRequest : NSObject

/// Instantiate a new card tokenization request.
///
/// @param card A card. Cannot be `nil`.
///
/// @return A card tokenization request.
- (instancetype)initWithCard:(BTCard *)card NS_DESIGNATED_INITIALIZER;

- (instancetype)init __attribute__((unavailable("Please use initWithCard:")));

/// The card to tokenize.
@property (nonatomic, strong) BTCard *card;

/// A mobile phone number. Used by Union Pay to enroll cards.
///
/// @warning Do not include the country code when setting this! Instead, use `mobileCountryCode`
@property (nonatomic, copy, nullable) NSString *mobilePhoneNumber;

/// The country code for the mobile phone number.
@property (nonatomic, copy, nullable) NSString *mobileCountryCode;

/// Controls whether or not to return validations and/or verification results. By default, this is
/// not enabled.
///
/// @warning Use this flag with caution. By enabling client-side validation, certain tokenize card
/// requests may result in adding the card to the vault. These semantics are not currently documented.
@property (nonatomic, assign) BOOL shouldValidate;

@end

NS_ASSUME_NONNULL_END
