#import "BTKFormField.h"


@protocol BTKCardNumberFormFieldDelegate;

@class BTKCardType;

@interface BTKCardNumberFormField : BTKFormField

typedef NS_ENUM(NSInteger, BTKCardNumberFormFieldState) {
    BTKCardNumberFormFieldStateDefault = 0,
    BTKCardNumberFormFieldStateValidate,
    BTKCardNumberFormFieldStateLoading,
};

@property (nonatomic, strong, readonly) BTKCardType *cardType;
@property (nonatomic, strong) NSString *number;
@property (nonatomic) BTKCardNumberFormFieldState state;
@property (nonatomic, weak) id <BTKCardNumberFormFieldDelegate> cardNumberDelegate;

- (void)showCardHintAccessory;

@end

@protocol BTKCardNumberFormFieldDelegate <NSObject>

- (void)validateButtonPressed:(BTKFormField *)formField;

@end
