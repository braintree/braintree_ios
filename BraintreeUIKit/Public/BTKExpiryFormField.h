#import "BTKFormField.h"
#import "BTKExpiryInputView.h"

/// @class Form field to collect an expiration date.
@interface BTKExpiryFormField : BTKFormField <BTKExpiryInputViewDelegate>

/// The expiration month
@property (nonatomic, strong, nullable, readonly) NSString *expirationMonth;

/// The expiration year
@property (nonatomic, strong, nullable, readonly) NSString *expirationYear;

/// The expiration date in MMYYYY format.
@property (nonatomic, copy, nullable) NSString *expirationDate;

@end
