#import "BTKPostalCodeFormField.h"
#import "BTKUtil.h"
#import "BTKTextField.h"
#import "BTKLocalizedString.h"
#import "BTKInputAccessoryToolbar.h"

@implementation BTKPostalCodeFormField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textField.accessibilityLabel = BTKLocalizedString(POSTAL_CODE_PLACEHOLDER);
        self.formLabel.text = BTKLocalizedString(POSTAL_CODE_PLACEHOLDER);
        self.textField.placeholder = @"65350";
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.textField.inputAccessoryView = [[BTKInputAccessoryToolbar alloc] initWithDoneButtonForInput:self.textField];
        self.nonDigitsSupported = NO;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.textField.returnKeyType = UIReturnKeyDone;
    }
    return self;
}

- (void)setPostalCode:(NSString *)postalCode {
    if (!self.nonDigitsSupported) {
        NSString *numericPostalCode = [BTKUtil stripNonDigits:postalCode];
        if (![numericPostalCode isEqualToString:postalCode]) return;
    }
    _postalCode = postalCode;
    self.text = postalCode;
}

- (void)setNonDigitsSupported:(BOOL)nonDigitsSupported {
    _nonDigitsSupported = nonDigitsSupported;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
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
