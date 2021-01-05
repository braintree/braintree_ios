#import <Foundation/Foundation.h>

#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2BaseCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2BaseCustomization.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * Label customization options for 3D Secure 2 flows.
 */
@interface BTThreeDSecureV2LabelCustomization : BTThreeDSecureV2BaseCustomization

/**
 * @property headingTextColor Color code in Hex format. For example, the color code can be “#999999”.
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
