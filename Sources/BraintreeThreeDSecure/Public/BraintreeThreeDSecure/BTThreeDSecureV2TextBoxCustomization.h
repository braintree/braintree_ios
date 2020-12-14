#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The TextBoxCustomization class provides methods for the 3DS Requestor App to pass text box customization parameters to the 3DS SDK.
 */
@interface BTThreeDSecureV2TextBoxCustomization : NSObject

/**
 * @property borderWidth  Width (integer value) of the text box border.
 */
@property int borderWidth;

/**
 * @property borderColor Colour code in Hex format. For example, the colour code can be “#999999”.
 */
@property (nonatomic, strong) NSString* borderColor;

/**
 * @property cornerRadius Radius (integer value) for the text box corners.
 */
@property int cornerRadius;

@end

NS_ASSUME_NONNULL_END
