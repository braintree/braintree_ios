#import "BTKCardNumberFormField.h"
#import "BTKCardHint.h"
#import "BTKLocalizedString.h"
#import "BTKUtil.h"
#import "BTKTextField.h"
#import "BTKViewUtil.h"
#import "BTKInputAccessoryToolbar.h"
#import "BTKAppearance.h"

#define TEMP_KERNING 8.0

@interface BTKCardNumberFormField ()
@property (nonatomic, strong) BTKCardHint *hint;
@property (nonatomic, strong) UIButton *validateButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation BTKCardNumberFormField

@synthesize number = _number;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.state = BTKCardNumberFormFieldStateDefault;
        self.textField.accessibilityLabel = BTKLocalizedString(CARD_NUMBER_PLACEHOLDER);
        self.textField.placeholder = BTKLocalizedString(CARD_NUMBER_PLACEHOLDER);
        self.formLabel.text = @"";
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.textField.inputAccessoryView = [[BTKInputAccessoryToolbar alloc] initWithDoneButtonForInput:self.textField];

        self.hint = [BTKCardHint new];
        [self.hint setCardType:BTKPaymentOptionTypeUnknown];
        self.accessoryView = self.hint;
        [self setAccessoryViewHidden:YES animated:NO];
        
        self.validateButton = [UIButton new];
        [self.validateButton setTitle:@"Next" forState:UIControlStateNormal];
        
        NSAttributedString *normalValidateButtonString = [[NSAttributedString alloc] initWithString:@"Next" attributes:@{NSForegroundColorAttributeName:[BTKAppearance sharedInstance].tintColor, NSFontAttributeName:[UIFont fontWithName:[BTKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]]}];
        [self.validateButton setAttributedTitle:normalValidateButtonString forState:UIControlStateNormal];
        NSAttributedString *disabledValidateButtonString = [[NSAttributedString alloc] initWithString:@"Next" attributes:@{NSForegroundColorAttributeName:[BTKAppearance sharedInstance].disabledColor, NSFontAttributeName:[UIFont fontWithName:[BTKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]]}];
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
    NSUInteger maxLength = self.cardType == nil ? [BTKCardType maxNumberLength] : self.cardType.maxNumberLength;
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
    _number = [BTKUtil stripNonDigits:self.textField.text];
    BTKCardType *oldCardType = _cardType;
    _cardType = [BTKCardType cardTypeForNumber:_number];
    if (self.cardType != nil) {
        UITextRange *r = self.textField.selectedTextRange;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:[self.cardType formatNumber:_number kerning:TEMP_KERNING]];
        self.textField.attributedText = text;
        self.textField.selectedTextRange = r;
    }

    if (self.cardType != oldCardType) {
        [self updateCardHint];
    }
    
    self.displayAsValid = self.valid || (!self.isValidLength && self.isPotentiallyValid) || self.state == BTKCardNumberFormFieldStateValidate;
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
    self.formLabel.text = _number.length == 0 ? @"" : BTKLocalizedString(CARD_NUMBER_PLACEHOLDER);
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

- (void)setState:(BTKCardNumberFormFieldState)state {
    if (state == self.state) {
        return;
    }
    _state = state;
    if (self.state == BTKCardNumberFormFieldStateDefault) {
        self.accessoryView = self.hint;
        [self setAccessoryViewHidden:(self.formLabel.text.length <= 0) animated:YES];
    } else if (self.state == BTKCardNumberFormFieldStateLoading) {
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
    return self.state == BTKCardNumberFormFieldStateValidate;
}

- (BOOL)isValidCardType {
    return self.cardType != nil || _number.length == 0;
}

- (BOOL)isPotentiallyValid {
    return [BTKCardType possibleCardTypesForNumber:self.number].count > 0;
}

- (BOOL)isValidLength {
    return self.cardType != nil && [self.cardType completeNumber:_number];
}

- (void)updateCardHint {
    BTKPaymentOptionType paymentMethodType = [BTKViewUtil paymentMethodTypeForCardType:self.cardType];
    [self.hint setCardType:paymentMethodType animated:YES];
}

@end
