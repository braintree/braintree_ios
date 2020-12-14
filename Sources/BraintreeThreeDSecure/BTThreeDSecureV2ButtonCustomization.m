#import "BTThreeDSecureV2ButtonCustomization.h"
#import "BTThreeDSecureV2BaseCustomization_Internal.h"

@implementation BTThreeDSecureV2ButtonCustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.customization = [NSClassFromString(@"ButtonCustomization") new];
    }

    return self;
}

- (void)setBackgroundColor:(NSString *)backgroundColor {
    _backgroundColor = backgroundColor;
    if ([self.customization respondsToSelector:@selector(setBackgroundColor:)]) {
        [self.customization performSelector:@selector(setBackgroundColor:) withObject:backgroundColor];
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
