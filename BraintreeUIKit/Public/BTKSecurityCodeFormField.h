#import "BTKFormField.h"

/// @class Form field to collect a mobile country code
@interface BTKSecurityCodeFormField : BTKFormField

/// The security code
@property (nonatomic, copy, nullable, readonly) NSString *securityCode;

@end
