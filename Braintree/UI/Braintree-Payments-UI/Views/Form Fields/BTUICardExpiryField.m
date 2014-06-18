#import "BTUICardExpiryField.h"
#import "BTUIFormField_Protected.h"
#import "BTUIUtil.h"
#import "BTUICardExpirationValidator.h"
#import "BTUICardExpiryFormat.h"

@interface BTUICardExpiryField () <UITextFieldDelegate>
@end

@implementation BTUICardExpiryField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:@"MM/YY"
                                                                                        attributes:self.theme.textFieldPlaceholderAttributes];
        [self kernExpiration:placeholder];
        [self setThemedAttributedPlaceholder:placeholder];
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.textField.delegate = self;
    }
    return self;
}

- (BOOL)valid {
    if (!self.expirationYear || !self.expirationMonth) {
        return NO;
    }
    return [BTUICardExpirationValidator month:self.expirationMonth.intValue year:self.expirationYear.intValue validForDate:[NSDate date]];
}

#pragma mark - Handlers

- (void)fieldContentDidChange {
    _expirationMonth = nil;
    _expirationYear = nil;

    NSString *formattedValue;
    NSUInteger formattedCursorLocation;

    BTUICardExpiryFormat *format = [[BTUICardExpiryFormat alloc] init];
    format.value = self.textField.text;
    format.cursorLocation = [self.textField offsetFromPosition:self.textField.beginningOfDocument toPosition:self.textField.selectedTextRange.start];
    format.backspace = self.backspace;
    [format formattedValue:&formattedValue cursorLocation:&formattedCursorLocation];


    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:formattedValue attributes:self.theme.textFieldTextAttributes];
    [self kernExpiration:result];
    self.textField.attributedText = result;

    UITextPosition *newPosition = [self.textField positionFromPosition:self.textField.beginningOfDocument offset:formattedCursorLocation];
    UITextRange *newRange = [self.textField textRangeFromPosition:newPosition toPosition:newPosition];
    self.textField.selectedTextRange = newRange;

    NSArray *expirationComponents = [self.textField.text componentsSeparatedByString:@"/"];
    if(expirationComponents.count == 2 && self.textField.text.length == 5) {
        _expirationMonth = expirationComponents[0];
        _expirationYear = expirationComponents[1];
    }

    self.displayAsValid = self.textField.text.length != 5 || self.valid;

    [self.delegate formFieldDidChange:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [super textFieldDidBeginEditing:textField];
    self.displayAsValid = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidEndEditing:textField];
    self.displayAsValid = self.textField.text.length == 0 || self.valid;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)newText {

    NSString *numericNewText = [BTUIUtil stripNonDigits:newText];
    if (![numericNewText isEqualToString:newText]) {
        return NO;
    }
    NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:numericNewText];
    if(updatedText.length > 5) {
        return NO;
    }

    NSString *updatedNumberText = [BTUIUtil stripNonDigits:updatedText];

    NSString *monthStr = [updatedNumberText substringToIndex:MIN((NSUInteger)2, updatedNumberText.length)];
    if(monthStr.length > 0) {
        NSInteger month = [monthStr integerValue];
        if(month < 0 || 12 < month) {
            return NO;
        }
        if(monthStr.length >= 2 && month == 0) {
            return NO;
        }
    }
    
    return YES;
}


#pragma mark Helper

- (void)format {
    NSMutableString *s = [NSMutableString stringWithString:[BTUIUtil stripNonDigits:self.textField.text]];

    if (s.length == 0) {
        self.textField.attributedText = [[NSAttributedString alloc] initWithString:s];
        return;
    }

    if ([s characterAtIndex:0] > '1' && [s characterAtIndex:0] <= '9') {
        [s insertString:@"0" atIndex:0];
    }

    if (self.backspace) {
        if (s.length == 2) {
            [s deleteCharactersInRange:NSMakeRange(1, 1)];
        }
    }

    if (s.length > 2 && [s characterAtIndex:2] != '/' ) {
        [s insertString:@"/" atIndex:2];
    } else if (s.length == 2) {
        [s appendString:@"/"];
    }

    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:s attributes:self.theme.textFieldTextAttributes];
    [self kernExpiration:result];
    self.textField.attributedText = result;
}

- (void)kernExpiration:(NSMutableAttributedString *)input {
    [input removeAttribute:NSKernAttributeName range:NSMakeRange(0, input.length)];

    [input beginEditing];
    if (input.length > 2) {
        [input addAttribute:NSKernAttributeName value:@(self.theme.formattedEntryKerning/2) range:NSMakeRange(1, 1)];
        if (input.length > 3) {
            [input addAttribute:NSKernAttributeName value:@(self.theme.formattedEntryKerning/2) range:NSMakeRange(2, 1)];
        }
    }
    [input endEditing];
}


@end
