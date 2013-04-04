/*
 * Venmo SDK
 *
 ******************************
 * VTCheckboxView.h
 ******************************
 *
 * This view is required to be displayed where users enter their credit/debit card details.
 * It presents a description and checkbox that, when checked, stores the card info for
 * purchases in other apps.
 *
 * There is no VTCheckboxViewDelegate. This is just a view that you should add to your payment
 * entry form. All delegate callbacks are handled through the delegate of your VTClient.
 *
 * Custom public methods on VTCheckboxView are just for styling.
 *
 * You must use [client checkboxView] to alloc and init a VTCheckboxView.
 * Do NOT create a VTCheckboxView with [[VTCheckboxView alloc] init]
 *
 * The default size of a VTCheckboxView is 300 width x 66 height. The height can not be changed,
 * but the width can be set to any value greater than or equal to 280.
 */


#import <UIKit/UIKit.h>

@interface VTCheckboxView : UIView

// Sets the color of labels and button titles.
// The color of the "How it works" & "Terms of Service" links can't be
// changed right now right now.
@property (strong, nonatomic) UIColor *textColor; // default is nil (text draws black)

// Set the VTCheckboxView's background color using the default setBackgroundColor method on UIView.

// Convenience method to set the width of the VTCheckboxView.
// Width must be >= 280
- (void)setWidth:(CGFloat)newWidth;

// Convenience method to set the origin of the VTCheckboxView.
- (void)setOrigin:(CGPoint)newOrigin;

@end
