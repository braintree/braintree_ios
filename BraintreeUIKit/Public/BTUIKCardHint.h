#import <UIKit/UIKit.h>
#import "BTUIKPaymentOptionType.h"

/// `BTCardHint` has two display modes: one emphasizes the card type, and the second emphasizes the CVV location.
typedef NS_ENUM(NSInteger, BTUIKCardHintDisplayMode) {
    /// Emphasize the card's type.
    BTUIKCardHintDisplayModeCardType,
    /// Emphasize the CVV's location.
    BTUIKCardHintDisplayModeCVVHint,
};

/// A View that displays a card icon in order to provide users with a hint as to what card type
/// has been detected or where the CVV can be found on that card.
@interface BTUIKCardHint : UIView

/// The card type to display.
@property (nonatomic, assign) BTUIKPaymentOptionType cardType;

/// Whether to emphasize the card type or the CVV.
@property (nonatomic, assign) BTUIKCardHintDisplayMode displayMode;

/// Whether it is highlighted with the tint color
@property (nonatomic, assign) BOOL highlighted;

/// Set highlight with animation
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

/// Update the current cardType with an optional visual animation
/// @see cardType
- (void)setCardType:(BTUIKPaymentOptionType)cardType animated:(BOOL)animated;

/// Update the current displayMode with an optional visual animation
/// @see displayMode
- (void)setDisplayMode:(BTUIKCardHintDisplayMode)displayMode animated:(BOOL)animated;

@end
