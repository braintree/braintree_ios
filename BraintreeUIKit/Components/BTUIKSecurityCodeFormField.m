#import "BTUIKSecurityCodeFormField.h"
#import "BTUIKCardHint.h"
#import "BTUIKTextField.h"
#import "BTUIKInputAccessoryToolbar.h"

@interface BTUIKSecurityCodeFormField ()

@property (nonatomic, retain) BTUIKCardHint* hint;

@end

@implementation BTUIKSecurityCodeFormField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textField.accessibilityLabel = @"Security Code";
        self.formLabel.text = @"Security Code";
        self.textField.placeholder = @"CVN2";
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.hint = [BTUIKCardHint new];
        [self.hint setHighlighted:YES];
        self.hint.displayMode = BTUIKCardHintDisplayModeCVVHint;
        self.accessoryView = self.hint;
        [self setAccessoryViewHidden:YES animated:NO];
        
        self.textField.inputAccessoryView = [[BTUIKInputAccessoryToolbar alloc] initWithDoneButtonForInput:self.textField];
    }
    return self;
}

#pragma mark - Custom accessors

- (BOOL)valid {
    return self.securityCode.length >= 3;
}

- (NSString *)securityCode {
    return self.textField.text;
}

#pragma mark - Protocol conformance

#pragma mark UITextFieldDelegate

- (void)fieldContentDidChange {
    [self.delegate formFieldDidChange:self];
    [self updateAppearance];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [super textFieldDidBeginEditing:textField];
    [self setAccessoryViewHidden:NO animated:YES];
    [self updateAppearance];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidEndEditing:textField];
    [self setAccessoryViewHidden:YES animated:YES];
    [self updateAppearance];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return textField.text.length - range.length + string.length <= 4;
}

@end
