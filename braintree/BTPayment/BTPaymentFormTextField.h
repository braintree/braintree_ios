/*
 * Venmo SDK
 *
 ******************************
 * BTPaymentFormTextField.h
 ******************************
 *
 * This is used in the BTPaymentFormView to apply custom and consistent UITextField styling quickly.
 */

#import <UIKit/UIKit.h>

@interface BTPaymentFormTextField : UITextField

@property (strong, nonatomic) UIColor *defaultTextColor;

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate;
- (void)resetTextColor;

@end
