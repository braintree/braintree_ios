#import <UIKit/UIKit.h>
#import "BTKPaymentOptionType.h"

/// @class A UIView containing the BTKVectorArtView for a BTKPaymentOptionType within a light border.
@interface BTKPaymentOptionCardView : UIView

/// The BTKPaymentOptionType to display
@property (nonatomic) BTKPaymentOptionType paymentOptionType;

/// Set the highlighted state of the view.
///
/// @param highlighted When true, change the border color to the tint color. Otherwise light gray.
- (void)setHighlighted:(BOOL)highlighted;

/// Use the art dimensions to ensure that the width/height ratio is
/// appropriate.
///
/// @return A CGSize. Usually CGSizeMake(87.0f, 55.0f)
- (CGSize)getArtDimensions;

@end
