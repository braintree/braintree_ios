#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The Customization class serves as a superclass for the ButtonCustomization class, ToolbarCustomization class, LabelCustomization class, and TextBoxCustomization class.
 * This class provides methods to pass UI customization parameters to the 3DS SDK.
 */
@interface BTThreeDSecureV2BaseCustomization : NSObject

/**
 * @property textFontName Font type for the UI element.
 */
@property (nonatomic, strong) NSString* textFontName;

/**
 * @property textColor Color code in Hex format. For example, the color code can be “#999999”.
 */
@property (nonatomic, strong) NSString* textColor;

/**
 * @property textFontSize Font size for the UI element.
 */
@property (nonatomic) int textFontSize;

@end

NS_ASSUME_NONNULL_END
