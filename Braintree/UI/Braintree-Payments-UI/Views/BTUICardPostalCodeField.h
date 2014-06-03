#import "BTUIFormField.h"

@interface BTUICardPostalCodeField : BTUIFormField

@property (nonatomic, strong, readonly) NSString *postalCode;
@property (nonatomic, assign) BOOL nonDigitsSupported;

@end
