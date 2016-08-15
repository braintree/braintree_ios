#import "BTUIKAppearance.h"
#import "UIColor+BTUIK.h"

@implementation BTUIKAppearance

+ (instancetype) sharedInstance {
    static BTUIKAppearance *sharedTheme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTheme = [BTUIKAppearance new];
        [sharedTheme lightTheme];
    });
    
    return sharedTheme;
}

- (void) lightTheme {
    self.overlayColor = [UIColor btuik_colorFromHex:@"000000" alpha:0.5];
    self.tintColor = [UIColor btuik_colorFromHex:@"2489F6" alpha:1.0];
    self.barBackgroundColor = [UIColor whiteColor];
    self.fontFamily = [UIFont systemFontOfSize:10].fontName;
    self.boldFontFamily = [UIFont boldSystemFontOfSize:10].fontName;
    self.formBackgroundColor = [UIColor groupTableViewBackgroundColor];
    self.formFieldBackgroundColor = [UIColor whiteColor];
    self.primaryTextColor = [UIColor blackColor];
    self.secondaryTextColor = [UIColor btuik_colorFromHex:@"666666" alpha:1.0];
    self.disabledColor = [UIColor lightGrayColor];
    self.placeholderTextColor = [UIColor lightGrayColor];
    self.lineColor = [UIColor btuik_colorFromHex:@"BFBFBF" alpha:1.0];
    self.errorForegroundColor = [UIColor btuik_colorFromHex:@"ff3b30" alpha:1.0];
    self.blurStyle = UIBlurEffectStyleExtraLight;
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.useBlurs = YES;
    self.postalCodeFormFieldKeyboardType = UIKeyboardTypeNumberPad;
}

- (void) darkTheme {
    self.overlayColor = [UIColor btuik_colorFromHex:@"000000" alpha:0.5];
    self.tintColor = [UIColor btuik_colorFromHex:@"2489F6" alpha:1.0];
    self.barBackgroundColor = [UIColor btuik_colorFromHex:@"222222" alpha:1.0];
    self.fontFamily = [UIFont systemFontOfSize:10].fontName;
    self.boldFontFamily = [UIFont boldSystemFontOfSize:10].fontName;
    self.formBackgroundColor = [UIColor btuik_colorFromHex:@"222222" alpha:1.0];
    self.formFieldBackgroundColor = [UIColor btuik_colorFromHex:@"333333" alpha:1.0];
    self.primaryTextColor = [UIColor whiteColor];
    self.secondaryTextColor = [UIColor btuik_colorFromHex:@"999999" alpha:1.0];
    self.disabledColor = [UIColor lightGrayColor];
    self.placeholderTextColor = [UIColor btuik_colorFromHex:@"8E8E8E" alpha:1.0];
    self.lineColor = [UIColor btuik_colorFromHex:@"666666" alpha:1.0];
    self.errorForegroundColor = [UIColor btuik_colorFromHex:@"ff3b30" alpha:1.0];
    self.blurStyle = UIBlurEffectStyleDark;
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.useBlurs = YES;
    self.postalCodeFormFieldKeyboardType = UIKeyboardTypeNumberPad;
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
        sharedMetrics = @{@"HORIZONTAL_FORM_PADDING":@([self horizontalFormContentPadding]),
                          @"FORM_CELL_HEIGHT":@([self formCellHeight]),
                          @"VERTICAL_FORM_SPACE":@([self verticalFormSpace]),
                          @"VERTICAL_FORM_SPACE_TIGHT":@([self verticalFormSpaceTight]),
                          @"VERTICAL_SECTION_SPACE":@([self verticalSectionSpace]),
                          @"ICON_WIDTH":@([self smallIconWidth]),
                          @"ICON_HEIGHT":@([self smallIconHeight]),
                          @"LARGE_ICON_WIDTH":@([self largeIconWidth]),
                          @"LARGE_ICON_HEIGHT":@([self largeIconHeight])};
    });
    
    return sharedMetrics;
}

@end
