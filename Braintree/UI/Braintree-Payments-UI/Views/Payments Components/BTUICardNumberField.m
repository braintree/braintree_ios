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
        [hint setCardType:BTUIPaymentMethodTypeUnknown];
        self.accessoryView = hint;
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
        [self updateCardHint];
    }

    self.displayAsValid = self.valid || (!self.isValidLength && self.isPotentiallyValid);

    [self updateAppearance];
    [self setNeedsDisplay];

    [self.delegate formFieldDidChange:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [super textFieldDidBeginEditing:textField];
    self.displayAsValid = self.valid || (!self.isValidLength && self.isPotentiallyValid);
    [self updateAppearance];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidEndEditing:textField];
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

- (void)updateCardHint {
    BTUIPaymentMethodType paymentMethodType = [BTUIViewUtil paymentMethodTypeForCardType:self.cardType];
    BTUICardHint *hint =(BTUICardHint *)self.accessoryView;
    [hint setCardType:paymentMethodType animated:YES];
}



@end
