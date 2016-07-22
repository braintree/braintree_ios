#import "BTUIKMobileCountryCodeFormField.h"
#import "BTUIKTextField.h"
#import "BTUIKInputAccessoryToolbar.h"

@implementation BTUIKMobileCountryCodeFormField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textField.accessibilityLabel = @"Mobile Country Code";
        self.formLabel.text = @"Mobile Country Code";
        self.textField.placeholder = @"+65";
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.textField.inputAccessoryView = [[BTUIKInputAccessoryToolbar alloc] initWithDoneButtonForInput:self.textField];
    }
    return self;
}

- (void)fieldContentDidChange {
    
    NSMutableString *s = [NSMutableString stringWithString:self.textField.text];
    NSUInteger slashLocation = [s rangeOfString:@"+"].location;
    if (slashLocation == NSNotFound && s.length > 0) {
        [s insertString:@"+" atIndex:0];
    } else if (s.length == 1) {
        s = [NSMutableString stringWithString:@""];
    }
    
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:s];
    self.textField.attributedText = result;
    
    [self updateAppearance];
    [self.delegate formFieldDidChange:self];
}

#pragma mark - Custom accessors

- (BOOL)valid {
    return self.countryCode.length >= 1;
}

- (NSString *)countryCode {
    return [self.textField.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
}

@end
