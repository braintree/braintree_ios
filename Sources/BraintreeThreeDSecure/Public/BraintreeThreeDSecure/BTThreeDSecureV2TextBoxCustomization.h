#import <Foundation/Foundation.h>

#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2BaseCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2BaseCustomization.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * Text box customization options for 3D Secure 2 flows.
 */
@interface BTThreeDSecureV2TextBoxCustomization : BTThreeDSecureV2BaseCustomization

/**
 * @property borderWidth  Width (integer value) of the text box border.
 */
@property (nonatomic) int borderWidth;

/**
 * @property borderColor Color code in Hex format. For example, the color code can be “#999999”.
 */
@property (nonatomic, strong) NSString* borderColor;

/**
 * @property cornerRadius Radius (integer value) for the text box corners.
 */
@property (nonatomic) int cornerRadius;

@end

NS_ASSUME_NONNULL_END
