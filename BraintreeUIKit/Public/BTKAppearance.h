#import <UIKit/UIKit.h>

@interface BTKAppearance : NSObject

/// Shared instance used by Form elements
+ (instancetype) sharedInstance;

/// Fallback color for the overlay if blur is disabled
@property (nonatomic, strong) UIColor *overlayColor;
/// Tint color, defaults to 007aff
@property (nonatomic, strong) UIColor *tintColor;
/// Bar color
@property (nonatomic, strong) UIColor *barBackgroundColor;
/// Font family to be used for all labels and buttons
@property (nonatomic, strong) NSString *fontFamily;
/// Sheet background color
@property (nonatomic, strong) UIColor *sheetBackgroundColor;
/// Form field background color
@property (nonatomic, strong) UIColor *formFieldBackgroundColor;
/// Primary text color
@property (nonatomic, strong) UIColor *primaryTextColor;
/// Secondary text color
@property (nonatomic, strong) UIColor *secondaryTextColor;
/// Color of disabled buttons
@property (nonatomic, strong) UIColor *disabledColor;
/// Placeholder text color for form fields
@property (nonatomic, strong) UIColor *placeholderTextColor;
/// Line and border color
@property (nonatomic, strong) UIColor *lineColor;
/// Error background color
@property (nonatomic, strong) UIColor *errorBackgroundColor;
/// Error foreground color
@property (nonatomic, strong) UIColor *errorForegroundColor;
/// Blur style
@property (nonatomic) UIBlurEffectStyle blurStyle;
/// Toggle blur effects
@property (nonatomic) BOOL useBlurs;

/// Sets the color (primary or secondary) and font with family and size (large or small)
/// These properties are on the [BTKAppearance sharedInstance]
+ (void) styleLabelPrimary:(UILabel *) label;
+ (void) styleSmallLabelPrimary:(UILabel *)label;
+ (void) styleLabelSecondary:(UILabel *)label;
+ (void) styleLargeLabelSecondary:(UILabel *)label;

+ (UIColor *)payBlue;
+ (UIColor *)palBlue;

+ (UIColor *)errorBackgroundColor;
+ (UIColor *)errorForegroundColor;

+ (UIColor *)blackTextColor;
+ (UIColor *)darkGrayTextColor;

+ (UIColor *)grayBorderColor;
+ (UIColor *)lightGrayBorderColor;

+ (float)textFieldOverlayPadding;

@end
