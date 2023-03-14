//
//  UiCustomization.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ButtonCustomization.h"
#import "ToolbarCustomization.h"
#import "LabelCustomization.h"
#import "TextBoxCustomization.h"

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
@interface UiCustomization : NSObject

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

/**
 * Returns a ButtonCustomization object.
 * @param buttonType A pre-defined list of button types.
 * @return ButtonCustomization
 */
- (ButtonCustomization *)getButtonCustomization:(ButtonType)buttonType;

/**
 * Returns a ButtonCustomization object for an implementer-specific button type.
 * @param buttonType Implementer-specific button type.
 * @return ButtonCustomization
 */
- (ButtonCustomization *)getButtonCustomizationFromString:(NSString *)buttonType;

/**
 * Returns a ToolbarCustomization object.
 * @return ToolbarCustomization
 */
- (ToolbarCustomization *)getToolbarCustomization;

/**
 * Returns a LabelCustomization object.
 * @return LabelCustomization
 */
- (LabelCustomization *)getLabelCustomization;

/**
 * Returns a TextBoxCustomization object.
 * @return TextBoxCustomization
 */
- (TextBoxCustomization *)getTextBoxCustomization;

@end
