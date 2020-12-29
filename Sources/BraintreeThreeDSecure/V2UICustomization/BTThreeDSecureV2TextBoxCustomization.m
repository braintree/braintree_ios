#import "BTThreeDSecureV2BaseCustomization_Internal.h"

#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2TextBoxCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2TextBoxCustomization.h>
#endif

@implementation BTThreeDSecureV2TextBoxCustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cardinalValue = [NSClassFromString(@"TextBoxCustomization") new];
    }

    return self;
}

- (void)setBorderWidth:(int)borderWidth {
    _borderWidth = borderWidth;
    if ([self.cardinalValue respondsToSelector:@selector(setBorderWidth:)]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.cardinalValue methodSignatureForSelector:@selector(setBorderWidth:)]];
        [inv setSelector:@selector(setBorderWidth:)];
        [inv setTarget:self.cardinalValue];

        [inv setArgument:&(borderWidth) atIndex:2];
        [inv invoke];
    }
}

- (void)setBorderColor:(NSString *)borderColor {
    _borderColor = borderColor;
    if ([self.cardinalValue respondsToSelector:@selector(setBorderColor:)]) {
        [self.cardinalValue performSelector:@selector(setBorderColor:) withObject:borderColor];
    }
}

- (void)setCornerRadius:(int)cornerRadius {
    _cornerRadius = cornerRadius;
    if ([self.cardinalValue respondsToSelector:@selector(setCornerRadius:)]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.cardinalValue methodSignatureForSelector:@selector(setCornerRadius:)]];
        [inv setSelector:@selector(setCornerRadius:)];
        [inv setTarget:self.cardinalValue];

        [inv setArgument:&(cornerRadius) atIndex:2];
        [inv invoke];
    }
}

@end
