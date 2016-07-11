#import <UIKit/UIKit.h>
#import "BTUIKTextField.h"

@protocol BTUIKFormFieldDelegate;

/// @class A UIView containing a BTUIKTextField and other elements to be displayed as a form field. This class is meant to be extended but can be used as is for other generic form fields.
@interface BTUIKFormField : UIView <UITextFieldDelegate, UIKeyInput>

/// The delegate for this form field
@property (nonatomic, weak) id<BTUIKFormFieldDelegate> delegate;
/// Whether to vibrate on invalid input
@property (nonatomic, assign) BOOL vibrateOnInvalidInput;
/// Is the form field currently valid, this does not imply it is completed
@property (nonatomic, assign, readonly) BOOL valid;
/// Is the entry completed
@property (nonatomic, assign, readonly) BOOL entryComplete;
/// Whether to display as valid
@property (nonatomic, assign) BOOL displayAsValid;
/// Should show a bottom border
@property (nonatomic, assign) BOOL bottomBorder;
/// Should show a top border
@property (nonatomic, assign) BOOL topBorder;
/// Should show an inter bottom border
@property (nonatomic, assign) BOOL interFieldBorder;
/// Whether to allow backspace
@property (nonatomic, assign, readwrite) BOOL backspace;

/// The text displayed by the field
@property (nonatomic, copy) NSString *text;
/// The text field
@property (nonatomic, strong) BTUIKTextField* textField;
/// The label
@property (nonatomic, strong) UILabel* formLabel;
/// The accessory view shown opposite the label
@property (nonatomic, strong) UIView *accessoryView;

/// Updates the appearance of the form field (e.g if it is invalid it will appear with error colors)
- (void)updateAppearance;
/// Update constraints
- (void)updateConstraints;
/// Set the accessory view visibility
/// @param hidden The desired hidden state
/// @param animated Whether to animate when updating the visibility
- (void)setAccessoryViewHidden:(BOOL)hidden animated:(BOOL)animated;
/// To be implemented by subclasses. Otherwise does nothing.
- (void)resetFormField;

@end

/// @protocol Required by the delegate
@protocol BTUIKFormFieldDelegate <NSObject>

/// Called when the content changes
- (void)formFieldDidChange:(BTUIKFormField *)formField;

@optional
/// Use to override the default behavior or returning `YES` for textFieldShouldReturn.
- (BOOL)formFieldShouldReturn:(BTUIKFormField *)formField;
/// Did begin editing
- (void)formFieldDidBeginEditing:(BTUIKFormField *)formField;
/// Did end editing
- (void)formFieldDidEndEditing:(BTUIKFormField *)formField;

@end
