#import "BTThreeDSecureV2BaseCustomization_Internal.h"

#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2ButtonCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2ButtonCustomization.h>
#endif

@implementation BTThreeDSecureV2ButtonCustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cardinalValue = [NSClassFromString(@"ButtonCustomization") new];
    }

    return self;
}

- (void)setBackgroundColor:(NSString *)backgroundColor {
    _backgroundColor = backgroundColor;
    if ([self.cardinalValue respondsToSelector:@selector(setBackgroundColor:)]) {
        [self.cardinalValue performSelector:@selector(setBackgroundColor:) withObject:backgroundColor];
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
