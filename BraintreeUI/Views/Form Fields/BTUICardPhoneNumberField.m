#import "BTUICardPhoneNumberField.h"
#import "BTUIFormField_Protected.h"
#import "BTUILocalizedString.h"
@import Contacts;

@implementation BTUICardPhoneNumberField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setThemedPlaceholder:BTUILocalizedString(PHONE_NUMBER_PLACEHOLDER)];
        self.textField.accessibilityLabel = BTUILocalizedString(PHONE_NUMBER_PLACEHOLDER);
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return self;
}

- (BOOL)valid {
    return self.textField.text.length > 0;
}

- (NSString *)phoneNumber {
    return self.textField.text;
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    self.textField.text = phoneNumber;
}

- (void)fieldContentDidChange {
    if ([self.delegate respondsToSelector:@selector(formFieldDidChange:)]) {
        [self.delegate formFieldDidChange:self];
    }
}

@end
