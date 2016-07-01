#import "BTKAppearance.h"
#import "UIColor+BTK.h"

@implementation BTKAppearance

+ (instancetype) sharedInstance {
    static BTKAppearance *sharedTheme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTheme = [BTKAppearance new];
        sharedTheme.overlayColor = [UIColor BTK_colorFromHex:@"000000" alpha:0.7];
        sharedTheme.tintColor = [UIColor BTK_colorFromHex:@"007aff" alpha:1.0];
        sharedTheme.barBackgroundColor = [UIColor whiteColor];
        sharedTheme.fontFamily = [UIFont systemFontOfSize:10].familyName;
        sharedTheme.sheetBackgroundColor = [UIColor groupTableViewBackgroundColor];
        sharedTheme.formFieldBackgroundColor = [UIColor whiteColor];
        sharedTheme.primaryTextColor = [BTKAppearance blackTextColor];
        sharedTheme.secondaryTextColor = [BTKAppearance darkGrayTextColor];
        sharedTheme.disabledColor = [UIColor lightGrayColor];
        sharedTheme.placeholderTextColor = [UIColor lightGrayColor];
        sharedTheme.lineColor = [BTKAppearance lightGrayBorderColor];
        sharedTheme.errorBackgroundColor = [BTKAppearance errorBackgroundColor];
        sharedTheme.errorForegroundColor = [BTKAppearance errorForegroundColor];
        sharedTheme.blurStyle = UIBlurEffectStyleDark;
        sharedTheme.useBlurs = YES;
    });
    
    return sharedTheme;
}

+ (void) styleLabelPrimary:(UILabel *)label {
    label.font = [UIFont fontWithName:[BTKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]];
    label.textColor = [BTKAppearance sharedInstance].primaryTextColor;
}

+ (void) styleSmallLabelPrimary:(UILabel *)label {
    label.font = [UIFont fontWithName:[BTKAppearance sharedInstance].fontFamily size:[UIFont smallSystemFontSize]];
    label.textColor = [BTKAppearance sharedInstance].primaryTextColor;
}

+ (void) styleLabelSecondary:(UILabel *)label {
    label.font = [UIFont fontWithName:[BTKAppearance sharedInstance].fontFamily size:[UIFont smallSystemFontSize]];
    label.textColor = [BTKAppearance sharedInstance].secondaryTextColor;
}

+ (void) styleLargeLabelSecondary:(UILabel *)label {
    label.font = [UIFont fontWithName:[BTKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]];
    label.textColor = [BTKAppearance sharedInstance].secondaryTextColor;
}

+ (UIColor *)payBlue {
    return [UIColor BTK_colorFromHex:@"003087" alpha:1.0f];
}

+ (UIColor *)palBlue {
    return [UIColor BTK_colorFromHex:@"009CDE" alpha:1.0f];
}

+ (UIColor *)errorBackgroundColor {
    return [UIColor BTK_colorWithBytesR:250 G:229 B:232];
}

+ (UIColor *)errorForegroundColor {
    return [UIColor BTK_colorWithBytesR:208 G:2 B:27];
}

+ (UIColor *)blackTextColor {
    return [UIColor BTK_colorFromHex:@"000000" alpha:1.0];
}

+ (UIColor *)darkGrayTextColor {
    return [UIColor BTK_colorFromHex:@"666666" alpha:1.0];
}

+ (UIColor *)grayBorderColor {
    return [UIColor BTK_colorFromHex:@"C8C7CC" alpha:1.0];
}

+ (UIColor *)lightGrayBorderColor {
    return [UIColor BTK_colorFromHex:@"000000" alpha:0.15];
}

+ (float)textFieldOverlayPadding {
    return 5.0f;
}

@end
