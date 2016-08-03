#import "BTUIKCardNumberFormField.h"
#import "BTUIKCardHint.h"
#import "BTUIKLocalizedString.h"
#import "BTUIKUtil.h"
#import "BTUIKTextField.h"
#import "BTUIKViewUtil.h"
#import "BTUIKInputAccessoryToolbar.h"
#import "BTUIKAppearance.h"

#define TEMP_KERNING 8.0

@interface BTUIKCardNumberFormField ()
@property (nonatomic, strong) BTUIKCardHint *hint;
@property (nonatomic, strong) UIButton *validateButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation BTUIKCardNumberFormField

@synthesize number = _number;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.state = BTUIKCardNumberFormFieldStateDefault;
        self.textField.accessibilityLabel = BTUIKLocalizedString(CARD_NUMBER_PLACEHOLDER);
        self.textField.placeholder = BTUIKLocalizedString(CARD_NUMBER_PLACEHOLDER);
        self.formLabel.text = @"";
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.textField.inputAccessoryView = [[BTUIKInputAccessoryToolbar alloc] initWithDoneButtonForInput:self.textField];

        self.hint = [BTUIKCardHint new];
        [self.hint setCardType:BTUIKPaymentOptionTypeUnknown];
        self.accessoryView = self.hint;
        [self setAccessoryViewHidden:YES animated:NO];
        
        self.validateButton = [UIButton new];
        [self.validateButton setTitle:@"Next" forState:UIControlStateNormal];
        
        NSAttributedString *normalValidateButtonString = [[NSAttributedString alloc] initWithString:@"Next" attributes:@{NSForegroundColorAttributeName:[BTUIKAppearance sharedInstance].tintColor, NSFontAttributeName:[UIFont fontWithName:[BTUIKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]]}];
        [self.validateButton setAttributedTitle:normalValidateButtonString forState:UIControlStateNormal];
        NSAttributedString *disabledValidateButtonString = [[NSAttributedString alloc] initWithString:@"Next" attributes:@{NSForegroundColorAttributeName:[BTUIKAppearance sharedInstance].disabledColor, NSFontAttributeName:[UIFont fontWithName:[BTUIKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]]}];
        [self.validateButton setAttributedTitle:disabledValidateButtonString forState:UIControlStateDisabled];

        [self.validateButton sizeToFit];
        [self.validateButton layoutIfNeeded];
        [self.validateButton addTarget:self action:@selector(validateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self updateValidationButton];

        self.loadingView = [UIActivityIndicatorView new];
        self.loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.loadingView sizeToFit];
    }
    return self;
}

- (void)validateButtonPressed {
    if (self.cardNumberDelegate != nil) {
        [self.cardNumberDelegate validateButtonPressed:self];
    }
}

- (void)updateValidationButton {
    self.validateButton.enabled = _number.length > 13;
}

- (BOOL)valid {
    return [self.cardType validNumber:self.number];
}

- (BOOL)entryComplete {
    return [super entryComplete] && [self.cardType validAndNecessarilyCompleteNumber:self.number];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = textField.text.length - range.length + string.length;
    NSUInteger maxLength = self.cardType == nil ? [BTUIKCardType maxNumberLength] : self.cardType.maxNumberLength;
    if ([self isShowingValidateButton]) {
        return YES;
    } else {
        return newLength <= maxLength;
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self fieldContentDidChange];
}

- (void)fieldContentDidChange {
    _number = [BTUIKUtil stripNonDigits:self.textField.text];
    BTUIKCardType *oldCardType = _cardType;
    _cardType = [BTUIKCardType cardTypeForNumber:_number];
    if (self.cardType != nil) {
        UITextRange *r = self.textField.selectedTextRange;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:[self.cardType formatNumber:_number kerning:TEMP_KERNING]];
        self.textField.attributedText = text;
        self.textField.selectedTextRange = r;
    }

    if (self.cardType != oldCardType) {
        [self updateCardHint];
    }
    
    self.displayAsValid = self.valid || (!self.isValidLength && self.isPotentiallyValid) || self.state == BTUIKCardNumberFormFieldStateValidate;
    [self updateValidationButton];
    [self updateAppearance];
    [self setNeedsDisplay];
    
    [self.delegate formFieldDidChange:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [super textFieldDidBeginEditing:textField];
    self.displayAsValid = self.valid || (!self.isValidLength && self.isPotentiallyValid);
    self.formLabel.text = @"";
    [UIView transitionWithView:self
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if ([self isShowingValidateButton]) {
                            [self setAccessoryViewHidden:NO animated:NO];
                        } else {
                            [self setAccessoryViewHidden:YES animated:YES];
                        }
                        [self updateConstraints];
                        [self updateAppearance];
                    } completion:nil];

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidEndEditing:textField];
    self.displayAsValid = _number.length == 0 || (_cardType != nil && [_cardType validNumber:_number]);
    self.formLabel.text = _number.length == 0 ? @"" : BTUIKLocalizedString(CARD_NUMBER_PLACEHOLDER);
    [UIView animateWithDuration:0.2 animations:^{
        if ([self isShowingValidateButton]) {
            [self setAccessoryViewHidden:NO animated:NO];
        } else {
            if (_number.length == 0) {
                [self setAccessoryViewHidden:YES animated:YES];
            } else {
                [self showCardHintAccessory];
            }
        }
        [self updateConstraints];
        [self updateAppearance];
    }];
}

- (void)resetFormField {
    self.formLabel.text = @"";
    self.textField.text = @"";
    [self setAccessoryViewHidden:YES animated:NO];
    [self updateConstraints];
    [self updateAppearance];
}

#pragma mark - Public Methods

- (void)setState:(BTUIKCardNumberFormFieldState)state {
    if (state == self.state) {
        return;
    }
    _state = state;
    if (self.state == BTUIKCardNumberFormFieldStateDefault) {
        self.accessoryView = self.hint;
        [self setAccessoryViewHidden:(self.formLabel.text.length <= 0) animated:YES];
    } else if (self.state == BTUIKCardNumberFormFieldStateLoading) {
        self.accessoryView = self.loadingView;
        [self setAccessoryViewHidden:NO animated:YES];
        [self.loadingView startAnimating];
    } else {
        self.accessoryView = self.validateButton;
        [self setAccessoryViewHidden:NO animated:YES];
    }
}

- (void)setNumber:(NSString *)number {
    self.text = number;
    _number = self.textField.text;
}

- (void)showCardHintAccessory {
    [self setAccessoryViewHidden:NO animated:YES];
}

#pragma mark - Private Helpers

- (BOOL)isShowingValidateButton {
    return self.state == BTUIKCardNumberFormFieldStateValidate;
}

- (BOOL)isValidCardType {
    return self.cardType != nil || _number.length == 0;
}

- (BOOL)isPotentiallyValid {
    return [BTUIKCardType possibleCardTypesForNumber:self.number].count > 0;
}

- (BOOL)isValidLength {
    return self.cardType != nil && [self.cardType completeNumber:_number];
}

- (void)updateCardHint {
    BTUIKPaymentOptionType paymentMethodType = [BTUIKViewUtil paymentMethodTypeForCardType:self.cardType];
    [self.hint setCardType:paymentMethodType animated:YES];
}

@end
