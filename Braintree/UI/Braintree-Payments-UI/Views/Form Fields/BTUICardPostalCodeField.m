#import "BTUICardPostalCodeField.h"
#import "BTUIFormField_Protected.h"

@implementation BTUICardPostalCodeField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setThemedPlaceholder:@"Postal Code"];
        self.nonDigitsSupported = NO;
    }
    return self;
}

- (void)setNonDigitsSupported:(BOOL)nonDigitsSupported {
    _nonDigitsSupported = nonDigitsSupported;
    self.textField.keyboardType = _nonDigitsSupported ? UIKeyboardTypeNumbersAndPunctuation : UIKeyboardTypeNumberPad;
}

- (BOOL)valid {
    return self.postalCode.length > 0;
}

- (void)fieldContentDidChange {
    _postalCode = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.displayAsValid = YES;
    [super fieldContentDidChange];
    [self.delegate formFieldDidChange:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.displayAsValid = YES;
    [super textFieldDidBeginEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.displayAsValid = YES;
    [super textFieldDidEndEditing:textField];
}

@end
