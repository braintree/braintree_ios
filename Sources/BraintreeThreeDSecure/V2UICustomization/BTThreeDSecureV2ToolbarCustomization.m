#import "BTThreeDSecureV2BaseCustomization_Internal.h"

#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2ToolbarCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2ToolbarCustomization.h>
#endif

@implementation BTThreeDSecureV2ToolbarCustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cardinalValue = [ToolbarCustomization new];
    }

    return self;
}

- (void)setBackgroundColor:(NSString *)backgroundColor {
    _backgroundColor = backgroundColor;
    ((ToolbarCustomization *)self.cardinalValue).backgroundColor = backgroundColor;
}

- (void)setHeaderText:(NSString *)headerText {
    _headerText = headerText;
    ((ToolbarCustomization *)self.cardinalValue).headerText = headerText;
}

- (void)setButtonText:(NSString *)buttonText {
    _buttonText = buttonText;
    ((ToolbarCustomization *)self.cardinalValue).buttonText = buttonText;
}

@end
