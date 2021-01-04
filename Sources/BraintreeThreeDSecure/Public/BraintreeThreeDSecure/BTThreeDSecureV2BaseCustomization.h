#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Base customization options for 3D Secure 2 flows.
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
