#import <Foundation/Foundation.h>
#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2UICustomization.h>
#import <Braintree/BTThreeDSecureV2LabelCustomization.h>
#import <Braintree/BTThreeDSecureV2ButtonCustomization.h>
#import <Braintree/BTThreeDSecureV2TextBoxCustomization.h>
#import <Braintree/BTThreeDSecureV2ToolbarCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2UICustomization.h>
#import <BraintreeThreeDSecure/BTThreeDSecureV2LabelCustomization.h>
#import <BraintreeThreeDSecure/BTThreeDSecureV2ButtonCustomization.h>
#import <BraintreeThreeDSecure/BTThreeDSecureV2TextBoxCustomization.h>
#import <BraintreeThreeDSecure/BTThreeDSecureV2ToolbarCustomization.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * The ButtonType enum defines the button type.
 */
typedef NS_ENUM(NSInteger, BTThreeDSecureV2ButtonType) {
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
};

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
- (void)setButtonCustomization:(BTThreeDSecureV2ButtonCustomization *)buttonCustomization
                     buttonType:(BTThreeDSecureV2ButtonType)buttonType;

/**
 * Sets the attributes of a ToolbarCustomization object.
 * @param toolbarCustomization A ToolbarCustomization object.
 */
@property (nonatomic, strong) BTThreeDSecureV2ToolbarCustomization *toolbarCustomization;

/**
 * Sets the attributes of a LabelCustomization object.
 * @param labelCustomization A LabelCustomization object.
 */
@property (nonatomic, strong) BTThreeDSecureV2LabelCustomization *labelCustomization;

/**
 * Sets the attributes of a TextBoxCustomization object.
 * @param textBoxCustomization A TextBoxCustomization object.
 */
@property (nonatomic, strong) BTThreeDSecureV2TextBoxCustomization *textBoxCustomization;

@end

NS_ASSUME_NONNULL_END
