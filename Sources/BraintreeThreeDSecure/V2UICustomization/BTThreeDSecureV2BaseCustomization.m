#import "BTThreeDSecureV2BaseCustomization_Internal.h"

@implementation BTThreeDSecureV2BaseCustomization

- (void)setTextFontName:(NSString *)textFontName {
    _textFontName = textFontName;
    self.cardinalValue.textFontName = textFontName;
}

- (void)setTextColor:(NSString *)textColor {
    _textColor = textColor;
    self.cardinalValue.textColor = textColor;
}

- (void)setTextFontSize:(int)textFontSize {
    _textFontSize = textFontSize;
    self.cardinalValue.textFontSize = textFontSize;
}

@end
