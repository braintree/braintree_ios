/*
 * Venmo SDK
 *
 ***********************************
 * BTPaymentActivityOverlayView.h
 ***********************************
 *
 * This is used in the BTPaymentFormView to apply custom UITextField styling quickly.
 * It darkens the screen and presents a UIView over the main view (but except the status bar)
 * with a customizable title (UILable) and loading indicator (UIActivityIndicatorView).
 */

#import <UIKit/UIKit.h>

@interface BTPaymentActivityOverlayView : UIView

@property (nonatomic, retain, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain, readonly) UILabel *titleLabel;

+ (id)sharedOverlayView; // default title is @"Loading..."

- (void)show;
- (void)dismissAnimated:(BOOL)animated;

@end
