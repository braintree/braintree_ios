#import <UIKit/UIKit.h>

@interface BTUIKAppearance : NSObject

/// Shared instance used by Form elements
+ (instancetype) sharedInstance;

+ (void) darkTheme;
+ (void) lightTheme;

/// Fallback color for the overlay if blur is disabled
@property (nonatomic, strong) UIColor *overlayColor;
/// Tint color, defaults to 007aff
@property (nonatomic, strong) UIColor *tintColor;
/// Bar color
@property (nonatomic, strong) UIColor *barBackgroundColor;
/// Font family
@property (nonatomic, strong) NSString *fontFamily;
/// Bold font family
@property (nonatomic, strong) NSString *boldFontFamily;
/// Sheet background color
@property (nonatomic, strong) UIColor *formBackgroundColor;
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
/// Error foreground color
@property (nonatomic, strong) UIColor *errorForegroundColor;
/// Blur style
@property (nonatomic) UIBlurEffectStyle blurStyle;
/// Activity indicator style
@property (nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle;
/// Toggle blur effects
@property (nonatomic) BOOL useBlurs;
/// The keyboard the postal code field should use
@property (nonatomic) UIKeyboardType postalCodeFormFieldKeyboardType;

/// Sets the color (primary or secondary) and font with family and size (large or small)
/// These properties are on the [BTUIKAppearance sharedInstance]
+ (void) styleLabelPrimary:(UILabel *) label;
+ (void) styleLabelBoldPrimary:(UILabel *) label;
+ (void) styleSmallLabelBoldPrimary:(UILabel *)label;
+ (void) styleSmallLabelPrimary:(UILabel *)label;
+ (void) styleLabelSecondary:(UILabel *)label;
+ (void) styleLargeLabelSecondary:(UILabel *)label;
+ (void) styleSystemLabelSecondary:(UILabel *)label;

+ (float) horizontalFormContentPadding;
+ (float) formCellHeight;
+ (float) verticalFormSpace;
+ (float) verticalFormSpaceTight;
+ (float) verticalSectionSpace;
+ (float) smallIconWidth;
+ (float) smallIconHeight;
+ (float) largeIconWidth;
+ (float) largeIconHeight;
+ (NSDictionary*)metrics;

@end
