#import "BTUICardPostalCodeField.h"
#import "BTUIFormField_Protected.h"
#import "BTUILocalizedString.h"

@implementation BTUICardPostalCodeField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setThemedPlaceholder:BTUILocalizedString(POSTAL_CODE_PLACEHOLDER)];
        self.nonDigitsSupported = NO;
    }
    return self;
}

- (void)setNonDigitsSupported:(BOOL)nonDigitsSupported {
    _nonDigitsSupported = nonDigitsSupported;
    self.textField.keyboardType = _nonDigitsSupported ? UIKeyboardTypeNumbersAndPunctuation : UIKeyboardTypeNumberPad;
}

- (BOOL)entryComplete {
    // Never allow auto-advancing out of postal code field since there is no way to know that the
    // input value constitutes a complete postal code.
    return NO;
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
