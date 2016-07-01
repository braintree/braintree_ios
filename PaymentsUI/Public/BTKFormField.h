#import <UIKit/UIKit.h>

@protocol BTKFormFieldDelegate;

@class BTKTextField;

@interface BTKFormField : UIView <UITextFieldDelegate, UIKeyInput>


@property (nonatomic, weak) id<BTKFormFieldDelegate> delegate;
@property (nonatomic, assign) BOOL vibrateOnInvalidInput;
@property (nonatomic, assign, readonly) BOOL valid;
@property (nonatomic, assign, readonly) BOOL entryComplete;
@property (nonatomic, assign) BOOL displayAsValid;
@property (nonatomic, assign) BOOL bottomBorder;
@property (nonatomic, assign) BOOL topBorder;
@property (nonatomic, assign) BOOL interFieldBorder;
@property (nonatomic, assign, readwrite) BOOL backspace;

/// The text displayed by the field
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) BTKTextField* textField;
@property (nonatomic, strong) UILabel* formLabel;
@property (nonatomic, strong) UIView *accessoryView;

- (void)updateAppearance;
- (void)updateConstraints;
- (void)setThemedAttributedPlaceholder:(NSAttributedString *)placeholder;
- (void)setAccessoryViewHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)resetFormField;

@end


@protocol BTKFormFieldDelegate <NSObject>

- (void)formFieldDidChange:(BTKFormField *)formField;
- (void)formFieldDidDeleteWhileEmpty:(BTKFormField *)formField;

@optional
- (BOOL)formFieldShouldReturn:(BTKFormField *)formField;
- (void)formFieldDidBeginEditing:(BTKFormField *)formField;
- (void)formFieldDidEndEditing:(BTKFormField *)formField;

@end
