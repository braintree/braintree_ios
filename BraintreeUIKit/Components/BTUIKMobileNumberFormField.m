#import "BTUIKMobileNumberFormField.h"
#import "BTUIKTextField.h"
#import "BTUIKInputAccessoryToolbar.h"

@implementation BTUIKMobileNumberFormField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textField.accessibilityLabel = @"Mobile Number";
        self.formLabel.text = @"Mobile Number";
        self.textField.placeholder = @"00 0000 0000";
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return self;
}

- (void)fieldContentDidChange {
    [self.delegate formFieldDidChange:self];
    [self updateAppearance];
}

#pragma mark - Custom accessors

- (BOOL)valid {
    return self.mobileNumber.length >= 8;
}

- (NSString *)mobileNumber {
    return self.textField.text;
}

@end
