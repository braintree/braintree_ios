#import "BTThreeDSecureV2UICustomization_Internal.h"
#import "BTThreeDSecureV2BaseCustomization_Internal.h"

@implementation BTThreeDSecureV2UICustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cardinalValue = [NSClassFromString(@"UiCustomization") new];
    }

    return self;
}

- (void)setButtonCustomization:(BTThreeDSecureV2ButtonCustomization *)buttonCustomization
                    buttonType:(BTThreeDSecureV2ButtonType)buttonType {
    if ([self.cardinalValue respondsToSelector:@selector(setButtonCustomization:buttonType:)]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.cardinalValue methodSignatureForSelector:@selector(setButtonCustomization:buttonType:)]];
        [inv setSelector:@selector(setButtonCustomization:buttonType:)];
        [inv setTarget:self.cardinalValue];

        [inv setArgument:&(buttonCustomization) atIndex:2];
        [inv setArgument:&(buttonType) atIndex:3];
        [inv invoke];
    }
}

- (void)setToolbarCustomization:(BTThreeDSecureV2ToolbarCustomization *)toolbarCustomization {
    _toolbarCustomization = toolbarCustomization;
    if ([self.cardinalValue respondsToSelector:@selector(setToolbarCustomization:)]) {
        [self.cardinalValue performSelector:@selector(setToolbarCustomization:) withObject:toolbarCustomization.cardinalValue];
    }
}

- (void)setLabelCustomization:(BTThreeDSecureV2LabelCustomization *)labelCustomization {
    _labelCustomization = labelCustomization;
    if ([self.cardinalValue respondsToSelector:@selector(setLabelCustomization:)]) {
        [self.cardinalValue performSelector:@selector(setLabelCustomization:) withObject:labelCustomization.cardinalValue];
    }
}

- (void)setTextBoxCustomization:(BTThreeDSecureV2TextBoxCustomization *)textBoxCustomization {
    _textBoxCustomization = textBoxCustomization;
    if ([self.cardinalValue respondsToSelector:@selector(setTextBoxCustomization:)]) {
        [self.cardinalValue performSelector:@selector(setTextBoxCustomization:) withObject:textBoxCustomization.cardinalValue];
    }
}

@end
