#import "BTThreeDSecureV2BaseCustomization_Internal.h"

#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2LabelCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2LabelCustomization.h>
#endif

@implementation BTThreeDSecureV2LabelCustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cardinalValue = [NSClassFromString(@"LabelCustomization") new];
    }

    return self;
}

- (void)setHeadingTextColor:(NSString *)headingTextColor {
    _headingTextColor = headingTextColor;
    if ([self.cardinalValue respondsToSelector:@selector(setHeadingTextColor:)]) {
        [self.cardinalValue performSelector:@selector(setHeadingTextColor:) withObject:headingTextColor];
    }
}

- (void)setHeadingTextFontName:(NSString *)headingTextFontName {
    _headingTextFontName = headingTextFontName;
    if ([self.cardinalValue respondsToSelector:@selector(setHeadingTextFontName:)]) {
        [self.cardinalValue performSelector:@selector(setHeadingTextFontName:) withObject:headingTextFontName];
    }
}

- (void)setHeadingTextFontSize:(int)headingTextFontSize {
    _headingTextFontSize = headingTextFontSize;
    if ([self.cardinalValue respondsToSelector:@selector(setHeadingTextFontSize:)]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.cardinalValue methodSignatureForSelector:@selector(setHeadingTextFontSize:)]];
        [inv setSelector:@selector(setHeadingTextFontSize:)];
        [inv setTarget:self.cardinalValue];

        [inv setArgument:&(headingTextFontSize) atIndex:2];
        [inv invoke];
    }
}

@end
