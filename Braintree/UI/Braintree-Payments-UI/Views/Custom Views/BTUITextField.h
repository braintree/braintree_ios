#import <UIKit/UIKit.h>

@protocol BTUITextFieldEditDelegate;

@interface BTUITextField : UITextField

@property (nonatomic, weak) id<BTUITextFieldEditDelegate> editDelegate;

@end

@protocol BTUITextFieldEditDelegate <NSObject>

@optional

- (void)textFieldWillDeleteBackward:(BTUITextField *)textField;
- (void)textFieldDidDeleteBackward:(BTUITextField *)textField
                      originalText:(NSString *)originalText;
- (void)textField:(BTUITextField *)textField willInsertText:(NSString *)text;
- (void)textField:(BTUITextField *)textField didInsertText:(NSString *)text;

@end