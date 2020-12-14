#import <Foundation/Foundation.h>

#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2BaseCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2BaseCustomization.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * The ToolbarCustomization class provides methods for the 3DS Requestor App to pass toolbar customization parameters to the 3DS SDK.
 */
@interface BTThreeDSecureV2ToolbarCustomization : BTThreeDSecureV2BaseCustomization

/**
 * @property backgroundColor Colour code in Hex format. For example, the colour code can be “#999999”.
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
