#import "BTUICardNumberField.h"
#import "BTUIFormField_Protected.h"
#import "BTUIUtil.h"
#import "BTUICardHint.h"
#import "BTUIViewUtil.h"

@implementation BTUICardNumberField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setThemedPlaceholder:@"Card Number"];
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        _number = @"";

        BTUICardHint *hint = [BTUICardHint new];
        [hint setCardType:BTUIPaymentMethodTypeAMEX];
        self.accessoryView = hint;
        self.accessoryView.alpha = 0.0f;
        self.accessoryView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.accessoryView];
    }
    return self;
}

- (BOOL)valid {
    return [self.cardType validNumber:self.number];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = textField.text.length - range.length + string.length;
    NSUInteger maxLength = self.cardType == nil ? [BTUICardType maxNumberLength] : self.cardType.maxNumberLength;
    return newLength <= maxLength;
}

- (void)fieldContentDidChange {
    _number = [BTUIUtil stripNonDigits:self.textField.text];
    BTUICardType *oldCardType = _cardType;
    _cardType = [BTUICardType cardTypeForNumber:_number];
    if (self.cardType != nil) {
        UITextRange *r = self.textField.selectedTextRange;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:[self.cardType formatNumber:_number kerning:self.theme.formattedEntryKerning]];
        [text addAttributes:self.theme.textFieldTextAttributes range:NSMakeRange(0, text.length)];
        self.textField.attributedText = text;
        self.textField.selectedTextRange = r;
    }
    if (self.cardType != oldCardType) {
        [self updateCardHint:oldCardType];
    }

    self.displayAsValid = self.valid || (!self.isValidLength && self.isPotentiallyValid);
    [self updateAppearance];
    [self setNeedsDisplay];

    [self.delegate formFieldDidChange:self];
}

- (void)textFieldDidBeginEditing:(__unused UITextField *)textField {
    self.displayAsValid = [self isPotentiallyValid];
    [self updateAppearance];
}

- (void)textFieldDidEndEditing:(__unused UITextField *)textField {
    self.displayAsValid = _number.length == 0 || (_cardType != nil && [_cardType validNumber:_number]);
    [self updateAppearance];
}

#pragma mark - Private Helpers

- (BOOL)isValidCardType {
    return self.cardType != nil || _number.length == 0;
}

- (BOOL)completedCardNumberValid {
    return self.cardType != nil && (self.cardType.maxNumberLength < _number.length || self.valid);
}

- (BOOL)isPotentiallyValid {
    return [BTUICardType possibleCardTypesForNumber:self.number].count > 0;
}

- (BOOL)isValidLength {
    return self.cardType != nil && [self.cardType completeNumber:_number];
}

- (void)updateCardHint:(BTUICardType *)oldCardType {
    BTUIPaymentMethodType paymentMethodType = [BTUIViewUtil paymentMethodTypeForCardType:self.cardType];
    BTUICardHint *hint =(BTUICardHint *)self.accessoryView;
    if (oldCardType == nil) {
        self.accessoryView.alpha = 0.0f;
        self.accessoryView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [hint setCardType:paymentMethodType animated:NO];
        [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:0.3f options:0 animations:^{
            self.accessoryView.alpha = 1.0f;
            self.accessoryView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    } else if(self.cardType == nil) {
        [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:0.3f options:0 animations:^{
            self.accessoryView.alpha = 0.0f;
        } completion:nil];
    } else {
        [hint setCardType:paymentMethodType animated:YES];
    }
}



@end
