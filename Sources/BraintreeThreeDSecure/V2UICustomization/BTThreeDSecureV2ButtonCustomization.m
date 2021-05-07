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
        self.cardinalValue = [ButtonCustomization new];
    }

    return self;
}

- (void)setBackgroundColor:(NSString *)backgroundColor {
    _backgroundColor = backgroundColor;
    ((ButtonCustomization *)self.cardinalValue).backgroundColor = backgroundColor;
}

- (void)setCornerRadius:(int)cornerRadius {
    _cornerRadius = cornerRadius;
    ((ButtonCustomization *)self.cardinalValue).cornerRadius = cornerRadius;
}

@end
