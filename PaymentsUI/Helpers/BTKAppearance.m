#import "BTKAppearance.h"
#import "UIColor+BTK.h"

@implementation BTKAppearance

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
