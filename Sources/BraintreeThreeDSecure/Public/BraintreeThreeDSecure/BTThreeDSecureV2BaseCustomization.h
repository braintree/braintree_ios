#import <Foundation/Foundation.h>
#import <CardinalMobile/CardinalMobile.h>

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

// TODO: can be internal again once this file is converted to Swift
@property (nonatomic, strong) Customization *cardinalValue;

@end

NS_ASSUME_NONNULL_END
