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
 * Button types that can be customized in 3D Secure 2 flows.
 */
typedef NS_ENUM(NSInteger, BTThreeDSecureV2ButtonType) {
    /** Verify button.*/
    ButtonTypeVerify,

    /** Continue button.*/
    ButtonTypeContinue,

    /** Next button.*/
    ButtonTypeNext,

    /** Cancel button.*/
    ButtonTypeCancel,

    /** Resend button.*/
    ButtonTypeResend
};

/**
 * UI customization options for 3D Secure 2 flows.
 */
@interface BTThreeDSecureV2UICustomization : NSObject

/**
 * Set button customization options for 3D Secure 2 flows.
 * @param buttonCustomization Button customization options
 * @param buttonType Button type
 */
- (void)setButtonCustomization:(BTThreeDSecureV2ButtonCustomization *)buttonCustomization
                     buttonType:(BTThreeDSecureV2ButtonType)buttonType;

/**
 * Toolbar customization options for 3D Secure 2 flows.
 */
@property (nonatomic, strong) BTThreeDSecureV2ToolbarCustomization *toolbarCustomization;

/**
 * Label customization options for 3D Secure 2 flows.
 */
@property (nonatomic, strong) BTThreeDSecureV2LabelCustomization *labelCustomization;

/**
 * Text box customization options for 3D Secure 2 flows.
 */
@property (nonatomic, strong) BTThreeDSecureV2TextBoxCustomization *textBoxCustomization;

@end

NS_ASSUME_NONNULL_END
