#import <UIKit/UIKit.h>
#import "BTUIFormField.h"

/// Private class extension for implementors of BTUIFormField subclasses.
@interface BTUIFormField () 

@property (nonatomic, strong, readonly) UITextField *textField;

@property (nonatomic, strong) UIView *accessoryView;

/// Override in your subclass to implement behavior
/// on content change
- (void)fieldContentDidChange;

/// Sets placeholder text with the appropriate theme style
- (void)setThemedPlaceholder:(NSString *)placeholder;
- (void)setThemedAttributedPlaceholder:(NSAttributedString *)placeholder;

@end

