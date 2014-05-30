#import "BTUI.h"

#import "BTUIMasterCardVectorArtView.h"
#import "BTUIJCBVectorArtView.h"
#import "BTUIMaestroVectorArtView.h"
#import "BTUIVisaVectorArtView.h"
#import "BTUIDiscoverVectorArtView.h"
#import "BTUIUnknownCardVectorArtView.h"
#import "BTUIPayPalMonogramColorView.h"
#import "BTUIDinersClubVectorArtView.h"
#import "BTUIAmExVectorArtView.h"

@implementation BTUI

+ (BTUI *)braintreeTheme {
    static BTUI *_sharedBraintreeTheme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedBraintreeTheme = [[BTUI alloc] init];
    });
    return _sharedBraintreeTheme;
}

- (UIColor *)idealGray {
    return [self colorWithBytesR:128 G:128 B:128];
}

- (UIColor *)viewBackgroundColor {
    return [self colorWithBytesR:251 G:251 B:251];
}

- (UIColor *)callToActionColor {
    return [self colorWithBytesR:7 G:158 B:222];
}

- (UIColor *)titleColor {
    return [self colorWithBytesR:46 G:51 B:58];
}

- (UIColor *)detailColor {
    return [self colorWithBytesR:98 G:102 B:105];
}

- (UIColor *)borderColor {
    return [self colorWithBytesR:216 G:216 B:216];
}

- (UIColor *)textFieldTextColor {
    return [self colorWithBytesR:26 G:26 B:26];
}

- (UIColor *)textFieldPlaceholderColor {
    return [self idealGray];
}

- (UIColor *)sectionHeaderTextColor {
    return [self idealGray];
}

- (UIColor *)highlightColor {
    return [self payPalButtonBlue];
}

- (UIColor *)cardHintBorderColor {
    return [self colorWithBytesR:0 G:0 B:0 A:20];
}

- (UIColor *)errorBackgroundColor {
    return [self colorWithBytesR:250 G:229 B:232];
}

- (UIColor *)errorForegroundColor {
    return [self colorWithBytesR:208 G:2 B:27];
}

#pragma mark PayPal Colors

- (UIColor *)payPalButtonBlue {
    return [self colorWithBytesR:1 G:156 B:222];
}

- (UIColor *)payPalButtonActiveBlue {
    return [self colorWithBytesR:12 G:141 B:196];
}

#pragma mark Utilities

- (UIColor *)colorWithBytesR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b A:(NSInteger)a {
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/255.0f];
}

- (UIColor *)colorWithBytesR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b {
    return [self colorWithBytesR:r G:g B:b A:255.0f];
}

#pragma mark - Appearance

- (CGFloat)cornerRadius {
    return 4.0f;
}

- (CGFloat)borderWidth {
    return 0.5f;
}

- (CGFloat)formattedEntryKerning {
    return 8.0f;
}

- (CGFloat)horizontalMargin {
    return 17.0f;
}

#pragma mark - Type

- (UIFont *)controlFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
}

- (UIFont *)controlTitleFont {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
}

- (UIFont *)controlDetailFont {
    return [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
}

- (UIFont *)textFieldFont {
    return [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
}

- (UIFont *)sectionHeaderFont {
    return [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
}

#pragma mark - String Attributes

- (NSDictionary *)textFieldTextAttributes {
    return @{NSFontAttributeName: self.textFieldFont,
             NSForegroundColorAttributeName: self.textFieldTextColor};
}

- (NSDictionary *)textFieldPlaceholderAttributes {
    return @{NSFontAttributeName: self.textFieldFont,
             NSForegroundColorAttributeName: self.textFieldPlaceholderColor};
}

#pragma mark Icons

- (BTUIVectorArtView *)vectorArtViewForPaymentMethodType:(BTUIPaymentMethodType)type {
    switch (type) {
        case BTUIPaymentMethodTypeVisa:
            return [BTUIVisaVectorArtView new];
        case BTUIPaymentMethodTypeMasterCard:
            return [BTUIMasterCardVectorArtView new];
        case BTUIPaymentMethodTypePayPal:
            return [BTUIPayPalMonogramColorView new];
        case BTUIPaymentMethodTypeDinersClub:
            return [BTUIDinersClubVectorArtView new];
        case BTUIPaymentMethodTypeJCB:
            return [BTUIJCBVectorArtView new];
        case BTUIPaymentMethodTypeMaestro:
            return [BTUIMaestroVectorArtView new];
        case BTUIPaymentMethodTypeDiscover:
            return [BTUIDiscoverVectorArtView new];
        case BTUIPaymentMethodTypeUKMaestro:
            return [BTUIMaestroVectorArtView new];
        case BTUIPaymentMethodTypeAMEX:
            return [BTUIAmExVectorArtView new];
        case BTUIPaymentMethodTypeSolo:
        case BTUIPaymentMethodTypeLaser:
        case BTUIPaymentMethodTypeSwitch:
        case BTUIPaymentMethodTypeUnionPay:
        case BTUIPaymentMethodTypeUnknown:
            return [BTUIUnknownCardVectorArtView new];
    }
}


@end

