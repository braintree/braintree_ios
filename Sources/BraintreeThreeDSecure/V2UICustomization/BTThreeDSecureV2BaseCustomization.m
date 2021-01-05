#import "BTThreeDSecureV2BaseCustomization_Internal.h"

@implementation BTThreeDSecureV2BaseCustomization

- (void)setTextFontName:(NSString *)textFontName {
    _textFontName = textFontName;
    if ([self.cardinalValue respondsToSelector:@selector(setTextFontName:)]) {
        [self.cardinalValue performSelector:@selector(setTextFontName:) withObject:textFontName];
    }
}

- (void)setTextColor:(NSString *)textColor {
    _textColor = textColor;
    if ([self.cardinalValue respondsToSelector:@selector(setTextColor:)]) {
        [self.cardinalValue performSelector:@selector(setTextColor:) withObject:textColor];
    }
}

- (void)setTextFontSize:(int)textFontSize {
    _textFontSize = textFontSize;
    if ([self.cardinalValue respondsToSelector:@selector(setTextFontSize:)]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.cardinalValue methodSignatureForSelector:@selector(setTextFontSize:)]];
        [inv setSelector:@selector(setTextFontSize:)];
        [inv setTarget:self.cardinalValue];

        [inv setArgument:&(textFontSize) atIndex:2];
        [inv invoke];
    }
}

- (int)getTextFontSize {
    return _textFontSize;
}

@end
