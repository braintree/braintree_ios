#import "BTThreeDSecureV2ToolbarCustomization.h"
#import "BTThreeDSecureV2BaseCustomization_Internal.h"

@implementation BTThreeDSecureV2ToolbarCustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.customization = [NSClassFromString(@"ToolbarCustomization") new];
    }

    return self;
}

- (void)setBackgroundColor:(NSString *)backgroundColor {
    _backgroundColor = backgroundColor;
    if ([self.customization respondsToSelector:@selector(setBackgroundColor:)]) {
        [self.customization performSelector:@selector(setBackgroundColor:) withObject:backgroundColor];
    }
}

- (void)setHeaderText:(NSString *)headerText {
    _headerText = headerText;
    if ([self.customization respondsToSelector:@selector(setHeaderText:)]) {
        [self.customization performSelector:@selector(setHeaderText:) withObject:headerText];
    }
}

- (void)setButtonText:(NSString *)buttonText {
    _buttonText = buttonText;
    if ([self.customization respondsToSelector:@selector(setButtonText:)]) {
        [self.customization performSelector:@selector(setButtonText:) withObject:buttonText];
    }
}

@end
