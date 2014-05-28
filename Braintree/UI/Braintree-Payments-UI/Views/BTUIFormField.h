#import <UIKit/UIKit.h>
#import "BTUIThemedView.h"

/// A form field is a UI component for entering a text value
///
/// This is the parent class of all card form fields,
/// and handles display but not formatting, validation, or
/// relaying of events
///
/// @see BTUIFormField()
@interface BTUIFormField : BTUIThemedView<UITextFieldDelegate>

- (void)updateAppearance;
- (void)becomeFirstResponder;

@property (nonatomic, assign, readonly) BOOL valid;
@property (nonatomic, assign, readonly) BOOL entryComplete;
@property (nonatomic, assign) BOOL displayAsValid;
@property (nonatomic, assign) BOOL bottomBorder;

@end

