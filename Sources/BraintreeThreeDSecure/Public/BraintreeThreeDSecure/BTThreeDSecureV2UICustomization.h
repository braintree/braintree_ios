#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The ButtonType enum defines the button type.
 */
typedef enum{
    /**ButtonTypeVerify Verify button.*/
    ButtonTypeVerify,

    /**ButtonTypeContinue Continue button.*/
    ButtonTypeContinue,

    /**ButtonTypeNext Next button.*/
    ButtonTypeNext,

    /**ButtonTypeCancel Cancel button.*/
    ButtonTypeCancel,

    /**ButtonTypeResend Resend button.*/
    ButtonTypeResend
}ButtonType;

/**
 * The UiCustomization class provides the functionality required to customize the 3DS SDK UI elements.
 * An object of this class holds various UI-related parameters.
 */
@interface BTThreeDSecureV2UICustomization : NSObject

/**
 * Set the attributes of a ButtonCustomization object for a particular predefined button type.
 * @param buttonCustomization A ButtonCustomization object.
 * @param buttonType ButtonType enum.
 */
- (void)setButtonCustomization:(ButtonCustomization *)buttonCustomization
                     buttonType:(ButtonType)buttonType;

/**
 * Set the attributes of a ButtonCustomization object for an implementer-specific button type.
 * @param buttonCustomization A ButtonCustomization object.
 * @param buttonType  Implementer-specific button type.
 */
- (void)setButtonCustomization:(ButtonCustomization *)buttonCustomization
               buttonTypeString:(NSString *)buttonType;

/**
 * Sets the attributes of a ToolbarCustomization object.
 * @param toolbarCustomization A ToolbarCustomization object.
 */
- (void)setToolbarCustomization:(ToolbarCustomization *)toolbarCustomization;

/**
 * Sets the attributes of a LabelCustomization object.
 * @param labelCustomization A LabelCustomization object.
 */
- (void)setLabelCustomization:(LabelCustomization *)labelCustomization;

/**
 * Sets the attributes of a TextBoxCustomization object.
 * @param textBoxCustomization A TextBoxCustomization object.
 */
- (void)setTextBoxCustomization:(TextBoxCustomization *)textBoxCustomization;

@end

NS_ASSUME_NONNULL_END
