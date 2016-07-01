#import "BTKMobileNumberFormField.h"
#import "BTKTextField.h"
#import "BTKInputAccessoryToolbar.h"

@implementation BTKMobileNumberFormField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textField.accessibilityLabel = @"Mobile Number";
        self.formLabel.text = @"Mobile Number";
        self.textField.placeholder = @"+65 00 0000 0000";
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.textField.inputAccessoryView = [[BTKInputAccessoryToolbar alloc] initWithDoneButtonForInput:self.textField];
    }
    return self;
}

- (void)fieldContentDidChange {
    [self.delegate formFieldDidChange:self];
}

#pragma mark - Custom accessors

- (BOOL)valid {
    return self.mobileNumber.length >= 9;
}

- (NSString *)mobileNumber {
    return self.textField.text;
}

@end
