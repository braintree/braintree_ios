#import "BTUITextField.h"

@interface BTUITextField ()

@end

@implementation BTUITextField

- (void)deleteBackward {
    NSString *textBeforeDelete = self.text;
    [super deleteBackward];
    if (self.deleteBackwardBlock != nil) {
        self.deleteBackwardBlock(textBeforeDelete, self);
    }
}

- (void)insertText:(NSString *)text {
    NSString *textBeforeInsert = self.text;
    [super insertText:text];
    if (self.insertTextBlock != nil) {
        self.insertTextBlock(textBeforeInsert, self);
    }
}

@end
