#import "BTUICardCvvField.h"
#import "BTUIFormField_Protected.h"
#import "BTUICardHint.h"
#import "BTUIUtil.h"

#define kMinimumCvvLength 3
#define kMaximumCvvLength 4

@interface BTUICardCvvField ()<UITextFieldDelegate>
@property (nonatomic, readonly) NSUInteger validLength;
@end

@implementation BTUICardCvvField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setThemedPlaceholder:@"CVV"];
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.textField.delegate = self;

        BTUICardHint *hint = [BTUICardHint new];
        hint.displayMode = BTCardHintDisplayModeCVVHint;
        self.accessoryView = hint;
        self.accessoryView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.accessoryView];
    }
    return self;
}

- (void)setCardType:(BTUICardType *)cardType {
    _cardType = cardType;
    self.displayAsValid = [self.textField isFirstResponder] || self.textField.text.length == 0 || self.valid;
    [self updateAppearance];
}

- (BOOL)valid {
    BOOL noCardTypeOKLength = (self.cardType == nil && self.cvv.length <= kMaximumCvvLength && self.cvv.length >= kMinimumCvvLength);
    BOOL validLengthForCardType = (self.cardType != nil && self.cvv.length == self.cardType.validCvvLength);
    return noCardTypeOKLength || validLengthForCardType;
}


- (BOOL)entryComplete {
    NSUInteger index = [self.textField offsetFromPosition:self.textField.beginningOfDocument toPosition:self.textField.selectedTextRange.start];
    BOOL cursorAtEnd = (index == self.textField.text.length);

    if (self.cardType == nil) {
        return cursorAtEnd && self.cvv.length == kMaximumCvvLength;
    } else {
        return self.valid;
    }
}

- (BOOL)textField:(__unused UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return string.length + range.location <= self.validLength;
}

- (NSUInteger)validLength {
    return self.cardType == nil ? kMaximumCvvLength : self.cardType.validCvvLength;
}

#pragma mark - Handlers

- (void)fieldContentDidChange {
    self.displayAsValid = YES;
    _cvv = [BTUIUtil stripNonDigits:self.textField.text];
    [self.delegate formFieldDidChange:self];
}

- (void)textFieldDidBeginEditing:(__unused UITextField *)textField {
    self.displayAsValid = YES;
    [(BTUICardHint *)self.accessoryView highlight:YES];
}

- (void)textFieldDidEndEditing:(__unused UITextField *)textField {
    self.displayAsValid = self.textField.text.length == 0 || self.valid;
    [(BTUICardHint *)self.accessoryView highlight:NO];
}


@end
