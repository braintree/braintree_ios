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
        self.cardinalValue = [TextBoxCustomization new];
    }

    return self;
}

- (void)setBorderWidth:(int)borderWidth {
    _borderWidth = borderWidth;
    ((TextBoxCustomization *)self.cardinalValue).borderWidth = borderWidth;
}

- (void)setBorderColor:(NSString *)borderColor {
    _borderColor = borderColor;
    ((TextBoxCustomization *)self.cardinalValue).borderColor = borderColor;
}

- (void)setCornerRadius:(int)cornerRadius {
    _cornerRadius = cornerRadius;
    ((TextBoxCustomization *)self.cardinalValue).cornerRadius = cornerRadius;
}

@end
