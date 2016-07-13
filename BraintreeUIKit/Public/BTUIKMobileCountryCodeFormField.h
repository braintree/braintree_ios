#import "BTUIKFormField.h"

/// @class Form field to collect a mobile country code
@interface BTUIKMobileCountryCodeFormField : BTUIKFormField

/// The country code
@property (nonatomic, copy, nullable, readonly) NSString *countryCode;

@end
