/*
 * Venmo SDK
 *
 ******************************
 * VTCardView.h
 ******************************
 *
 * This view allows you to suggest existing payment methods to your users, so they don't have to
 * type in their card details. You can style it and set its origin & bounds by using the public
 * methods provided below.
 *
 * There is no VTCardViewDelegate. This is just a view that you should add to your payment
 * entry form. All delegate callbacks are handled through the delegate of your VTClient.
 *
 * Custom public methods on VTCardView are just for styling.
 *
 * You must use [client cardView] to alloc and init a VTCardView.
 * Do NOT create a VTCardView with [[VTCardView alloc] init]
 *
 * The default size of a VTCardView is 300 width x 74 height. The height cannot be changed,
 * but the width can be set to any value greater than or equal to 280.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VTCardView : UIView

// Convenience method to set the corner radius of the "Use Card" button.
// Corner radius must be non-negative and no greater than 15 pixels. 0 <= cornerRadius <= 15
// Default is 4 pixels.
@property (nonatomic, assign) CGFloat cornerRadius;

// UI customization on the "Use Card" button
@property (nonatomic, strong) UIColor *useCardButtonBackgroundColor;
@property (nonatomic, strong) UIFont  *useCardButtonTitleFont; // default is [UIFont boldSystemFontOfSize:16]
@property (nonatomic, strong) UIFont  *infoButtonFont;         // default is [UIFont boldSystemFontOfSize:11]

// Convenience methods
- (void)setWidth:(CGFloat)newWidth; // Width must be >= 280
- (void)setOrigin:(CGPoint)origin;

@end
