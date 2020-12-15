#import "BTThreeDSecureV2LabelCustomization.h"
#import "BTThreeDSecureV2BaseCustomization_Internal.h"

@implementation BTThreeDSecureV2LabelCustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.customization = [NSClassFromString(@"LabelCustomization") new];
    }

    return self;
}

- (void)setHeadingTextColor:(NSString *)headingTextColor {
    _headingTextColor = headingTextColor;
    if ([self.customization respondsToSelector:@selector(setHeadingTextColor:)]) {
        [self.customization performSelector:@selector(setHeadingTextColor:) withObject:headingTextColor];
    }
}

- (void)setHeadingTextFontName:(NSString *)headingTextFontName {
    _headingTextFontName = headingTextFontName;
    if ([self.customization respondsToSelector:@selector(setHeadingTextFontName:)]) {
        [self.customization performSelector:@selector(setHeadingTextFontName:) withObject:headingTextFontName];
    }
}

- (void)setHeadingTextFontSize:(int)headingTextFontSize {
    _headingTextFontSize = headingTextFontSize;
    if ([self.customization respondsToSelector:@selector(setHeadingTextFontSize:)]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.customization methodSignatureForSelector:@selector(setHeadingTextFontSize:)]];
        [inv setSelector:@selector(setHeadingTextFontSize:)];
        [inv setTarget:self.customization];

        [inv setArgument:&(headingTextFontSize) atIndex:2];
        [inv invoke];
    }
}

@end
