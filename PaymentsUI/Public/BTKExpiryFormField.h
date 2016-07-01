#import "BTKFormField.h"
#import "BTKExpiryInputView.h"

@interface BTKExpiryFormField : BTKFormField <BTKExpiryInputViewDelegate>

@property (nonatomic, strong, nullable, readonly) NSString *expirationMonth;

@property (nonatomic, strong, nullable, readonly) NSString *expirationYear;

/// The expiration date in MMYYYY format.
@property (nonatomic, copy, nullable) NSString *expirationDate;

@end
