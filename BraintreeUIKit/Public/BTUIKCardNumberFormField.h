#import "BTUIKFormField.h"
#import "BTUIKCardType.h"

@protocol BTUIKCardNumberFormFieldDelegate;

/// @class Form field to collect a card number.
@interface BTUIKCardNumberFormField : BTUIKFormField

/// BTUIKCardNumberFormFieldState modifies the form field
/// Default: Allows the input of a number upto 16 digits and does Luhn checks for validity while editing.
/// Validate: Displays a `Next` button accessory view rather than validating while edting. Set the cardNumberDelegate to receive button press. Card numbers of any length can be entered.
/// Loading: Displays a loading indicator accessory view
typedef NS_ENUM(NSInteger, BTUIKCardNumberFormFieldState) {
    BTUIKCardNumberFormFieldStateDefault = 0,
    BTUIKCardNumberFormFieldStateValidate,
    BTUIKCardNumberFormFieldStateLoading,
};

/// The card type associated with the number currently being entered
@property (nonatomic, strong, readonly) BTUIKCardType *cardType;
/// The card number
@property (nonatomic, strong) NSString *number;
/// The state of the form
@property (nonatomic) BTUIKCardNumberFormFieldState state;
/// The delegate, primary used for validateButtonPressed calls
/// Not necessary unless using BTUIKCardNumberFormFieldStateValidate
@property (nonatomic, weak) id <BTUIKCardNumberFormFieldDelegate> cardNumberDelegate;

/// Whether to show the card hint accessory
- (void)showCardHintAccessory;

@end

/// @protocol This protocol is required by the delegate to receive the validateButtonPressed calls when using BTUIKCardNumberFormFieldStateValidate
@protocol BTUIKCardNumberFormFieldDelegate <NSObject>

- (void)validateButtonPressed:(BTUIKFormField *)formField;

@end
