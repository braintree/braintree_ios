#import "BTKFormField.h"

@interface BTKPostalCodeFormField : BTKFormField

@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, assign) BOOL nonDigitsSupported;

@end
