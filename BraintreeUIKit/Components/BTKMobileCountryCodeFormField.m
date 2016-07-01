#import "BTKMobileCountryCodeFormField.h"
#import "BTKTextField.h"
#import "BTKInputAccessoryToolbar.h"

@implementation BTKMobileCountryCodeFormField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textField.accessibilityLabel = @"Mobile Country Code";
        self.formLabel.text = @"Mobile Country Code";
        self.textField.placeholder = @"+65";
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.textField.inputAccessoryView = [[BTKInputAccessoryToolbar alloc] initWithDoneButtonForInput:self.textField];
    }
    return self;
}

- (void)fieldContentDidChange {
    [self.delegate formFieldDidChange:self];
    [self updateAppearance];
}

#pragma mark - Custom accessors

- (BOOL)valid {
    return self.countryCode.length >= 1;
}

- (NSString *)countryCode {
    return self.textField.text;
}

@end
