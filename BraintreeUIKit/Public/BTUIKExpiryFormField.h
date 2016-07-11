#import "BTUIKFormField.h"
#import "BTUIKExpiryInputView.h"

/// @class Form field to collect an expiration date.
@interface BTUIKExpiryFormField : BTUIKFormField <BTUIKExpiryInputViewDelegate>

/// The expiration month
@property (nonatomic, strong, nullable, readonly) NSString *expirationMonth;

/// The expiration year
@property (nonatomic, strong, nullable, readonly) NSString *expirationYear;

/// The expiration date in MMYYYY format.
@property (nonatomic, copy, nullable) NSString *expirationDate;

@end
