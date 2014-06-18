#import "BTUITextField.h"

@interface BTUITextField ()

@end

@implementation BTUITextField

- (void)deleteBackward {
    if (self.delegate && [self.editDelegate respondsToSelector:@selector(textFieldWillDeleteBackward:)]) {
        [self.editDelegate textFieldWillDeleteBackward:self];
    }
    NSString *originalText = self.text;
    [super deleteBackward];

    if (self.delegate && [self.editDelegate respondsToSelector:@selector(textFieldDidDeleteBackward:originalText:)]) {
        [self.editDelegate textFieldDidDeleteBackward:self originalText:originalText];
    }
}

- (void)insertText:(NSString *)text {
    if (self.delegate && [self.editDelegate respondsToSelector:@selector(textField:willInsertText:)]) {
        [self.editDelegate textField:self willInsertText:text];
    }

    [super insertText:text];

    if (self.delegate && [self.editDelegate respondsToSelector:@selector(textField:didInsertText:)]) {
        [self.editDelegate textField:self didInsertText:text];
    }
}

@end
