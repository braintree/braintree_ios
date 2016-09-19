#import "BTUIKAppearance.h"
#import "UIColor+BTUIK.h"

@implementation BTUIKAppearance

static BTUIKAppearance *sharedTheme;

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTheme = [BTUIKAppearance new];
        [BTUIKAppearance lightTheme];
    });
    
    return sharedTheme;
}

+ (void) lightTheme {
    sharedTheme.overlayColor = [UIColor btuik_colorFromHex:@"000000" alpha:0.5];
    sharedTheme.tintColor = [UIColor btuik_colorFromHex:@"2489F6" alpha:1.0];
    sharedTheme.barBackgroundColor = [UIColor whiteColor];
    sharedTheme.fontFamily = [UIFont systemFontOfSize:10].fontName;
    sharedTheme.boldFontFamily = [UIFont boldSystemFontOfSize:10].fontName;
    sharedTheme.formBackgroundColor = [UIColor groupTableViewBackgroundColor];
    sharedTheme.formFieldBackgroundColor = [UIColor whiteColor];
    sharedTheme.primaryTextColor = [UIColor blackColor];
    sharedTheme.secondaryTextColor = [UIColor btuik_colorFromHex:@"666666" alpha:1.0];
    sharedTheme.disabledColor = [UIColor lightGrayColor];
    sharedTheme.placeholderTextColor = [UIColor lightGrayColor];
    sharedTheme.lineColor = [UIColor btuik_colorFromHex:@"BFBFBF" alpha:1.0];
    sharedTheme.errorForegroundColor = [UIColor btuik_colorFromHex:@"ff3b30" alpha:1.0];
    sharedTheme.blurStyle = UIBlurEffectStyleExtraLight;
    sharedTheme.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    sharedTheme.useBlurs = YES;
    sharedTheme.postalCodeFormFieldKeyboardType = UIKeyboardTypeNumberPad;
}

+ (void) darkTheme {
    sharedTheme.overlayColor = [UIColor btuik_colorFromHex:@"000000" alpha:0.5];
    sharedTheme.tintColor = [UIColor btuik_colorFromHex:@"2489F6" alpha:1.0];
    sharedTheme.barBackgroundColor = [UIColor btuik_colorFromHex:@"222222" alpha:1.0];
    sharedTheme.fontFamily = [UIFont systemFontOfSize:10].fontName;
    sharedTheme.boldFontFamily = [UIFont boldSystemFontOfSize:10].fontName;
    sharedTheme.formBackgroundColor = [UIColor btuik_colorFromHex:@"222222" alpha:1.0];
    sharedTheme.formFieldBackgroundColor = [UIColor btuik_colorFromHex:@"333333" alpha:1.0];
    sharedTheme.primaryTextColor = [UIColor whiteColor];
    sharedTheme.secondaryTextColor = [UIColor btuik_colorFromHex:@"999999" alpha:1.0];
    sharedTheme.disabledColor = [UIColor lightGrayColor];
    sharedTheme.placeholderTextColor = [UIColor btuik_colorFromHex:@"8E8E8E" alpha:1.0];
    sharedTheme.lineColor = [UIColor btuik_colorFromHex:@"666666" alpha:1.0];
    sharedTheme.errorForegroundColor = [UIColor btuik_colorFromHex:@"ff3b30" alpha:1.0];
    sharedTheme.blurStyle = UIBlurEffectStyleDark;
    sharedTheme.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    sharedTheme.useBlurs = YES;
    sharedTheme.postalCodeFormFieldKeyboardType = UIKeyboardTypeNumberPad;
}   

+ (void) styleLabelPrimary:(UILabel *)label {
    label.font = [UIFont fontWithName:[BTUIKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]];
    label.textColor = [BTUIKAppearance sharedInstance].primaryTextColor;
}

+ (void) styleLabelBoldPrimary:(UILabel *)label {
    label.font = [UIFont fontWithName:[BTUIKAppearance sharedInstance].boldFontFamily size:[UIFont labelFontSize]];
    label.textColor = [BTUIKAppearance sharedInstance].primaryTextColor;
}

+ (void) styleSmallLabelBoldPrimary:(UILabel *)label {
    label.font = [UIFont fontWithName:[BTUIKAppearance sharedInstance].boldFontFamily size:[UIFont smallSystemFontSize]];
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

+ (void) styleSystemLabelSecondary:(UILabel *)label {
    label.font = [UIFont fontWithName:[BTUIKAppearance sharedInstance].fontFamily size:[UIFont systemFontSize]];
    label.textColor = [BTUIKAppearance sharedInstance].secondaryTextColor;
}

+ (float)horizontalFormContentPadding {
    return 15.0f;
}

+ (float)formCellHeight {
    return 44.0f;
}

+ (float)verticalFormSpace {
    return 35.0f;
}

+ (float)verticalFormSpaceTight {
    return 10.0f;
}

+ (float)verticalSectionSpace {
    return 30.0f;
}

+ (float)smallIconWidth {
    return 45.0;
}

+ (float)smallIconHeight {
    return 29.0;
}

+ (float)largeIconWidth {
    return 100.0;
}

+ (float)largeIconHeight {
    return 100.0;
}

+ (NSDictionary*)metrics {
    static NSDictionary *sharedMetrics;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMetrics = @{@"HORIZONTAL_FORM_PADDING":@([BTUIKAppearance horizontalFormContentPadding]),
                          @"FORM_CELL_HEIGHT":@([BTUIKAppearance formCellHeight]),
                          @"VERTICAL_FORM_SPACE":@([BTUIKAppearance verticalFormSpace]),
                          @"VERTICAL_FORM_SPACE_TIGHT":@([BTUIKAppearance verticalFormSpaceTight]),
                          @"VERTICAL_SECTION_SPACE":@([BTUIKAppearance verticalSectionSpace]),
                          @"ICON_WIDTH":@([BTUIKAppearance smallIconWidth]),
                          @"ICON_HEIGHT":@([BTUIKAppearance smallIconHeight]),
                          @"LARGE_ICON_WIDTH":@([BTUIKAppearance largeIconWidth]),
                          @"LARGE_ICON_HEIGHT":@([BTUIKAppearance largeIconHeight])};
    });
    
    return sharedMetrics;
}

@end
