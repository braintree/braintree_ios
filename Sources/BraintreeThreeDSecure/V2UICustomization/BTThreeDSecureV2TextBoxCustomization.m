#import "BTThreeDSecureV2TextBoxCustomization.h"
#import "BTThreeDSecureV2BaseCustomization_Internal.h"

@implementation BTThreeDSecureV2TextBoxCustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.customization = [NSClassFromString(@"TextBoxCustomization") new];
    }

    return self;
}

- (void)setBorderWidth:(int)borderWidth {
    _borderWidth = borderWidth;
    if ([self.customization respondsToSelector:@selector(setBorderWidth:)]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.customization methodSignatureForSelector:@selector(setBorderWidth:)]];
        [inv setSelector:@selector(setBorderWidth:)];
        [inv setTarget:self.customization];

        [inv setArgument:&(borderWidth) atIndex:2];
        [inv invoke];
    }
}

- (void)setBorderColor:(NSString *)borderColor {
    _borderColor = borderColor;
    if ([self.customization respondsToSelector:@selector(setBorderColor:)]) {
        [self.customization performSelector:@selector(setBorderColor:) withObject:borderColor];
    }
}

- (void)setCornerRadius:(int)cornerRadius {
    _cornerRadius = cornerRadius;
    if ([self.customization respondsToSelector:@selector(setCornerRadius:)]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.customization methodSignatureForSelector:@selector(setCornerRadius:)]];
        [inv setSelector:@selector(setCornerRadius:)];
        [inv setTarget:self.customization];

        [inv setArgument:&(cornerRadius) atIndex:2];
        [inv invoke];
    }
}

@end
