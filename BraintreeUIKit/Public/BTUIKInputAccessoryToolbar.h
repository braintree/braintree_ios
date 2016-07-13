#import <UIKit/UIKit.h>

/// @class Creates a toolbar with that can be used as an input accessory view.
@interface BTUIKInputAccessoryToolbar : UIToolbar

/// Creates a toolbar with a done button for the specified input (UITextField or UITextArea). Pressing this button dismisses the keyboard or input view.
- (instancetype)initWithDoneButtonForInput:(id <UITextInput>)input;

@end
