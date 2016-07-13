#import <UIKit/UIKit.h>

@protocol BTUIKTextFieldEditDelegate;

/// @class A specialized text field that provides more granular callbacks than a standard
/// UITextField as the user edits text
@interface BTUIKTextField : UITextField

/// The specialized delegate for receiving callbacks about editing
@property (nonatomic, weak) id<BTUIKTextFieldEditDelegate> editDelegate;

@property (nonatomic) BOOL hideCaret;

@end

/// A protocol for receiving callbacks when a user edits text in a `BTUITextField`
@protocol BTUIKTextFieldEditDelegate <NSObject>

@optional

/// The editDelegate receives this message when the user deletes a character, but before the deletion
/// is applied to the `text`
///
/// @param textField The text field
- (void)textFieldWillDeleteBackward:(BTUIKTextField *)textField;

/// The editDelegate receives this message after the user deletes a character
///
/// @param textField    The text field
/// @param originalText The `text` of the text field before applying the deletion
- (void)textFieldDidDeleteBackward:(BTUIKTextField *)textField
                      originalText:(NSString *)originalText;

/// The editDelegate receives this message when the user enters text, but
/// before the text is inserted
///
/// @param textField The text field
/// @param text      The text that will be inserted
- (void)textField:(BTUIKTextField *)textField willInsertText:(NSString *)text;

/// The editDelegate receives this message after the user enters text
///
/// @param textField The text field
/// @param text      The text that was inserted
- (void)textField:(BTUIKTextField *)textField didInsertText:(NSString *)text;
@end
