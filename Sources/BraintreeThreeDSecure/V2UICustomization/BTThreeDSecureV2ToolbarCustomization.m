#import "BTThreeDSecureV2BaseCustomization_Internal.h"

#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2ToolbarCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2ToolbarCustomization.h>
#endif

// To support SPM without an xcframework version of Cardinal, we created wrappers for Cardinal classes which are substituted for the actual CardinalMobile classes at runtime.
@implementation BTThreeDSecureV2ToolbarCustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cardinalValue = [NSClassFromString(@"ToolbarCustomization") new];
    }

    return self;
}

- (void)setBackgroundColor:(NSString *)backgroundColor {
    _backgroundColor = backgroundColor;
    if ([self.cardinalValue respondsToSelector:@selector(setBackgroundColor:)]) {
        [self.cardinalValue performSelector:@selector(setBackgroundColor:) withObject:backgroundColor];
    }
}

- (void)setHeaderText:(NSString *)headerText {
    _headerText = headerText;
    if ([self.cardinalValue respondsToSelector:@selector(setHeaderText:)]) {
        [self.cardinalValue performSelector:@selector(setHeaderText:) withObject:headerText];
    }
}

- (void)setButtonText:(NSString *)buttonText {
    _buttonText = buttonText;
    if ([self.cardinalValue respondsToSelector:@selector(setButtonText:)]) {
        [self.cardinalValue performSelector:@selector(setButtonText:) withObject:buttonText];
    }
}

@end
