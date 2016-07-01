#import "BTKFormField.h"

/// @class Form field to collect a postal code
@interface BTKPostalCodeFormField : BTKFormField

/// The postal code
@property (nonatomic, strong) NSString *postalCode;

/// Whether non-digits like "-" are supported
@property (nonatomic, assign) BOOL nonDigitsSupported;

@end
