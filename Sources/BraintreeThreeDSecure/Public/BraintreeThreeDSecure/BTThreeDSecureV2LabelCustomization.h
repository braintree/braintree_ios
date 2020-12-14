#import <Foundation/Foundation.h>

#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2BaseCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2BaseCustomization.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * The LabelCustomization class provides methods for the 3DS Requestor App to pass label customization parameters to the 3DS SDK.
 */
@interface BTThreeDSecureV2LabelCustomization : BTThreeDSecureV2BaseCustomization

/**
 * @property headingTextColor Colour code in Hex format. For example, the colour code can be “#999999”.
 */
@property (nonatomic, strong) NSString* headingTextColor;

/**
 * @property headingTextFontName Font type for the heading label text.
 */
@property (nonatomic, strong) NSString* headingTextFontName;

/**
 * @property headingTextFontSize Font size for the heading label text.
 */
@property (nonatomic) int headingTextFontSize;

@end

NS_ASSUME_NONNULL_END
