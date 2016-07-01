#import "BTKFormField.h"

/// @class Form field to collect a mobile country code
@interface BTKMobileCountryCodeFormField : BTKFormField

/// The country code
@property (nonatomic, copy, nullable, readonly) NSString *countryCode;

@end
