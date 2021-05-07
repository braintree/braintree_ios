#import "BTThreeDSecureV2UICustomization_Internal.h"
#import "BTThreeDSecureV2BaseCustomization_Internal.h"

@implementation BTThreeDSecureV2UICustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cardinalValue = [UiCustomization new];
    }

    return self;
}

- (void)setButtonCustomization:(BTThreeDSecureV2ButtonCustomization *)buttonCustomization
                    buttonType:(BTThreeDSecureV2ButtonType)buttonType {
    [self.cardinalValue setButtonCustomization:(ButtonCustomization *)buttonCustomization.cardinalValue
                                    buttonType:(ButtonType)buttonType];
}

- (void)setToolbarCustomization:(BTThreeDSecureV2ToolbarCustomization *)toolbarCustomization {
    _toolbarCustomization = toolbarCustomization;
    [self.cardinalValue setToolbarCustomization:(ToolbarCustomization *)toolbarCustomization.cardinalValue];
}

- (void)setLabelCustomization:(BTThreeDSecureV2LabelCustomization *)labelCustomization {
    _labelCustomization = labelCustomization;
    [self.cardinalValue setLabelCustomization:(LabelCustomization *)labelCustomization.cardinalValue];
}

- (void)setTextBoxCustomization:(BTThreeDSecureV2TextBoxCustomization *)textBoxCustomization {
    _textBoxCustomization = textBoxCustomization;
    [self.cardinalValue setTextBoxCustomization:(TextBoxCustomization *)textBoxCustomization.cardinalValue];
}

@end
