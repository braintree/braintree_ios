#import <Foundation/Foundation.h>

#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2BaseCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2BaseCustomization.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * The ButtonCustomization class provides methods for the 3DS Requestor App to pass button customization parameters to the 3DS SDK.
 */
@interface BTThreeDSecureV2ButtonCustomization : BTThreeDSecureV2BaseCustomization

/**
 * @property backgroundColor Colour code in Hex format. For example, the colour code can be “#999999”.
 */
@property (nonatomic, strong) NSString* backgroundColor;

/**
 * @property cornerRadius  Radius (integer value) for the button corners.
 */
@property (nonatomic) int cornerRadius;

@end

NS_ASSUME_NONNULL_END
