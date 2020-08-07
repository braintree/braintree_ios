#import "BTUIThemedView.h"

/**
 Optional card form fields
 */
typedef NS_OPTIONS(NSUInteger, BTUICardFormOptionalFields) {
    /// No optional fields
    BTUICardFormOptionalFieldsNone       = 0,

    /// Security code optional
    BTUICardFormOptionalFieldsCvv        = 1 << 0,

    /// Postal code optional
    BTUICardFormOptionalFieldsPostalCode = 1 << 1,

    /// Phone number optional
    BTUICardFormOptionalFieldsPhoneNumber= 1 << 2,

    /// All optional fields
    BTUICardFormOptionalFieldsAll        = BTUICardFormOptionalFieldsCvv | BTUICardFormOptionalFieldsPostalCode | BTUICardFormOptionalFieldsPhoneNumber
};

/**
 All card form fields.
 */
typedef NS_ENUM(NSUInteger, BTUICardFormField) {
    /// Card number
    BTUICardFormFieldNumber = 0,

    /// Expiration date
    BTUICardFormFieldExpiration,

    /// Security code
    BTUICardFormFieldCvv,

    /// Postal code
    BTUICardFormFieldPostalCode,

    /// Phone number
    BTUICardFormFieldPhoneNumber,
};

@protocol BTUICardFormViewDelegate;

/**
 A UIView to receive card information
 */
@interface BTUICardFormView : BTUIThemedView

/**
 The `BTUICardFormViewDelegate` to send change events to.
 */
@property (nonatomic, weak) IBOutlet id<BTUICardFormViewDelegate> delegate;

/**
 True if the card form data is valid. Otherwise false.
 */
@property (nonatomic, assign, readonly) BOOL valid;

/**
 The card number.

 If you set a card number longer than is allowed by the card type,
 it will not be set.
*/
@property (nonatomic, copy) NSString *number;

/**
 The card CVV

 @note this field is only visible when specified in `optionalFields`
*/
@property (nonatomic, copy) NSString *cvv;

/**
 The card billing address postal code for AVS verifications

 @note this field is only visible when specified in `optionalFields`
*/
@property (nonatomic, copy) NSString *postalCode;

/**
 The card expiration month
*/
@property (nonatomic, copy, readonly) NSString *expirationMonth;

/**
 The card expiration year
*/
@property (nonatomic, copy, readonly) NSString *expirationYear;

/**
 A phone number
*/
@property (nonatomic, copy, readonly) NSString *phoneNumber;

/**
 Sets the card form view's expiration date

 @param expirationDate The expiration date. Passing in `nil` will clear the
 card form's expiry field.
*/
- (void)setExpirationDate:(NSDate *)expirationDate;

/**
 Sets the card form view's expiration date

 @param expirationMonth The expiration month
 @param expirationYear The expiration year. Two-digit years are assumed to be 20xx.
*/
- (void)setExpirationMonth:(NSInteger)expirationMonth year:(NSInteger)expirationYear;

/**
 Immediately present a top level error message to the user.

 @param message The error message to present
*/
- (void)showTopLevelError:(NSString *)message;

/**
 Immediately present a field-level error to the user.

 @note We do not support field-level error descriptions. This method highlights the field to indicate invalidity.
 @param field The invalid field
*/
- (void)showErrorForField:(BTUICardFormField)field;

/**
 Configure whether to support complete alphanumeric postal codes. Defaults to YES
 @note If NO, allows only digit entry.
*/
@property (nonatomic, assign) BOOL alphaNumericPostalCode;

/**
 Which fields should be included. Defaults to BTUICardFormOptionalFieldsAll
*/
@property (nonatomic, assign) BTUICardFormOptionalFields optionalFields;

/**
 Whether to provide feedback to the user via vibration. Defaults to YES
*/
@property (nonatomic, assign) BOOL vibrate;

@end

/**
 Delegate protocol for receiving updates about the card form
*/
@protocol BTUICardFormViewDelegate <NSObject>

@optional

/**
 The card form data has updated.
*/
- (void)cardFormViewDidChange:(BTUICardFormView *)cardFormView;

/**
 The card form data did begin editing.
 */
- (void)cardFormViewDidBeginEditing:(BTUICardFormView *)cardFormView;

/**
 The card form data did end editing.
 */
- (void)cardFormViewDidEndEditing:(BTUICardFormView *)cardFormView;

@end
