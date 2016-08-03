#import "BTUIKAppearance.h"
#import "UIColor+BTUIK.h"

@implementation BTUIKAppearance

+ (instancetype) sharedInstance {
    static BTUIKAppearance *sharedTheme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTheme = [BTUIKAppearance new];
        sharedTheme.overlayColor = [UIColor btuik_colorFromHex:@"000000" alpha:0.7];
        sharedTheme.tintColor = [UIColor btuik_colorFromHex:@"007aff" alpha:1.0];
        sharedTheme.barBackgroundColor = [UIColor whiteColor];
        sharedTheme.fontFamily = [UIFont systemFontOfSize:10].familyName;
        sharedTheme.sheetBackgroundColor = [UIColor groupTableViewBackgroundColor];
        sharedTheme.formFieldBackgroundColor = [UIColor whiteColor];
        sharedTheme.primaryTextColor = [BTUIKAppearance blackTextColor];
        sharedTheme.secondaryTextColor = [BTUIKAppearance darkGrayTextColor];
        sharedTheme.disabledColor = [UIColor lightGrayColor];
        sharedTheme.placeholderTextColor = [UIColor lightGrayColor];
        sharedTheme.lineColor = [BTUIKAppearance lightGrayBorderColor];
        sharedTheme.errorBackgroundColor = [BTUIKAppearance errorBackgroundColor];
        sharedTheme.errorForegroundColor = [BTUIKAppearance errorForegroundColor];
        sharedTheme.blurStyle = UIBlurEffectStyleDark;
        sharedTheme.useBlurs = YES;
        sharedTheme.postalCodeFormFieldKeyboardType = UIKeyboardTypeNumberPad;
    });
    
    return sharedTheme;
}

+ (void) styleLabelPrimary:(UILabel *)label {
    label.font = [UIFont fontWithName:[BTUIKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]];
    label.textColor = [BTUIKAppearance sharedInstance].primaryTextColor;
}

+ (void) styleSmallLabelPrimary:(UILabel *)label {
    label.font = [UIFont fontWithName:[BTUIKAppearance sharedInstance].fontFamily size:[UIFont smallSystemFontSize]];
    label.textColor = [BTUIKAppearance sharedInstance].primaryTextColor;
}

+ (void) styleLabelSecondary:(UILabel *)label {
    label.font = [UIFont fontWithName:[BTUIKAppearance sharedInstance].fontFamily size:[UIFont smallSystemFontSize]];
    label.textColor = [BTUIKAppearance sharedInstance].secondaryTextColor;
}

+ (void) styleLargeLabelSecondary:(UILabel *)label {
    label.font = [UIFont fontWithName:[BTUIKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]];
    label.textColor = [BTUIKAppearance sharedInstance].secondaryTextColor;
}

+ (UIColor *)payBlue {
    return [UIColor btuik_colorFromHex:@"003087" alpha:1.0f];
}

+ (UIColor *)palBlue {
    return [UIColor btuik_colorFromHex:@"009CDE" alpha:1.0f];
}

+ (UIColor *)errorBackgroundColor {
    return [UIColor btuik_colorWithBytesR:250 G:229 B:232];
}

+ (UIColor *)errorForegroundColor {
    return [UIColor btuik_colorWithBytesR:208 G:2 B:27];
}

+ (UIColor *)blackTextColor {
    return [UIColor btuik_colorFromHex:@"000000" alpha:1.0];
}

+ (UIColor *)darkGrayTextColor {
    return [UIColor btuik_colorFromHex:@"666666" alpha:1.0];
}

+ (UIColor *)grayBorderColor {
    return [UIColor btuik_colorFromHex:@"C8C7CC" alpha:1.0];
}

+ (UIColor *)lightGrayBorderColor {
    return [UIColor btuik_colorFromHex:@"000000" alpha:0.15];
}

+ (float)textFieldOverlayPadding {
    return 5.0f;
}

+ (float)horizontalFormContentPadding {
    return 15.0f;
}

@end
