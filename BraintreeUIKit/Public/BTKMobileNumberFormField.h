#import "BTKFormField.h"

/// @class Form field to collect a mobile phone number
@interface BTKMobileNumberFormField : BTKFormField

/// The mobile phone number
@property (nonatomic, copy, nullable, readonly) NSString *mobileNumber;

@end
