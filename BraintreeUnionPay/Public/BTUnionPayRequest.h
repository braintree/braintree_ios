#if __has_include("BraintreeCard.h")
#import "BraintreeCard.h"
#else
#import <BraintreeCard/BraintreeCard.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// @class This class is used to handle UnionPay enrollment and tokenization. It wraps an
/// instance of `BTCard`, with additional properties for handling enrollment such as mobile
/// phone number and the auth code sent via SMS.

@interface BTUnionPayRequest : NSObject

/// Instantiates a Union Pay request object.
///
/// @param card The UnionPay card. Cannot be `nil`.
/// @param phoneNumber The mobile phone number to use to verify the enrollment via SMS.
///
/// @return An instance of `BTUnionPayRequest`, or `nil` if `card` or `phoneNumber` is `nil`.
- (instancetype)initWithCard:(BTCard *)card mobilePhoneNumber:(NSString *)phoneNumber;

/// The UnionPay card.
@property (nonatomic, strong) BTCard *card;

/// The mobile phone number to use to verify the enrollment via SMS.
@property (nonatomic, copy) NSString *mobilePhoneNumber;

/// The country code for the mobile phone number. This string should only contain digits.
/// By default, this is set to 62.
@property (nonatomic, copy) NSString *mobileCountryCode;

/// The enrollment auth code sent via SMS to the mobile phone number. The auth code is
/// needed to tokenize a UnionPay card that requires enrollment.
@property (nonatomic, copy, nullable) NSString *enrollmentAuthCode;

@end

NS_ASSUME_NONNULL_END
