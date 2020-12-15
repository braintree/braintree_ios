#import "BTThreeDSecureV2BaseCustomization_Internal.h"

@implementation BTThreeDSecureV2BaseCustomization

- (void)setTextFontName:(NSString *)textFontName {
    _textFontName = textFontName;
    if ([self.customization respondsToSelector:@selector(setTextFontName:)]) {
        [self.customization performSelector:@selector(setTextFontName:) withObject:textFontName];
    }
}

- (void)setTextColor:(NSString *)textColor {
    _textColor = textColor;
    if ([self.customization respondsToSelector:@selector(setTextColor:)]) {
        [self.customization performSelector:@selector(setTextColor:) withObject:textColor];
    }
}

- (void)setTextFontSize:(int)textFontSize {
    _textFontSize = textFontSize;
    if ([self.customization respondsToSelector:@selector(setTextFontSize:)]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.customization methodSignatureForSelector:@selector(setTextFontSize:)]];
        [inv setSelector:@selector(setTextFontSize:)];
        [inv setTarget:self.customization];

        [inv setArgument:&(textFontSize) atIndex:2];
        [inv invoke];
    }
}

- (int)getTextFontSize {
    return _textFontSize;
}

@end
