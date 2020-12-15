#import "BTThreeDSecureV2UICustomization_Internal.h"
#import "BTThreeDSecureV2BaseCustomization_Internal.h"

@implementation BTThreeDSecureV2UICustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.uiCustomization = [NSClassFromString(@"UiCustomization") new];
    }

    return self;
}

- (void)setButtonCustomization:(BTThreeDSecureV2ButtonCustomization *)buttonCustomization
                    buttonType:(BTThreeDSecureV2ButtonType)buttonType {
    if ([self.uiCustomization respondsToSelector:@selector(setButtonCustomization:buttonType:)]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.uiCustomization methodSignatureForSelector:@selector(setButtonCustomization:buttonType:)]];
        [inv setSelector:@selector(setButtonCustomization:buttonType::)];
        [inv setTarget:self.uiCustomization];

        [inv setArgument:&(buttonCustomization) atIndex:2];
        [inv setArgument:&(buttonType) atIndex:3];
        [inv invoke];
    }
}

- (void)setToolbarCustomization:(BTThreeDSecureV2ToolbarCustomization *)toolbarCustomization {
    _toolbarCustomization = toolbarCustomization;
    if ([self.uiCustomization respondsToSelector:@selector(setToolbarCustomization:)]) {
        [self.uiCustomization performSelector:@selector(setToolbarCustomization:) withObject:toolbarCustomization.customization];
    }
}

- (void)setLabelCustomization:(BTThreeDSecureV2LabelCustomization *)labelCustomization {
    _labelCustomization = labelCustomization;
    if ([self.uiCustomization respondsToSelector:@selector(setLabelCustomization:)]) {
        [self.uiCustomization performSelector:@selector(setLabelCustomization:) withObject:labelCustomization.customization];
    }
}

- (void)setTextBoxCustomization:(BTThreeDSecureV2TextBoxCustomization *)textBoxCustomization {
    _textBoxCustomization = textBoxCustomization;
    if ([self.uiCustomization respondsToSelector:@selector(setTextBoxCustomization:)]) {
        [self.uiCustomization performSelector:@selector(setTextBoxCustomization:) withObject:textBoxCustomization.customization];
    }
}

@end
