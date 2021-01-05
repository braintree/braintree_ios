#import <Foundation/Foundation.h>

#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2BaseCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2BaseCustomization.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * Toolbar customization options for 3D Secure 2 flows.
 */
@interface BTThreeDSecureV2ToolbarCustomization : BTThreeDSecureV2BaseCustomization

/**
 * @property backgroundColor Color code in Hex format. For example, the color code can be “#999999”.
 */
@property (nonatomic, strong) NSString* backgroundColor;

/**
 * @property headerText Text for the header.
 */
@property (nonatomic, strong) NSString* headerText;

/**
 * @property buttonText Text for the button. For example, “Cancel”.
 */
@property (nonatomic, strong) NSString* buttonText;

@end

NS_ASSUME_NONNULL_END
