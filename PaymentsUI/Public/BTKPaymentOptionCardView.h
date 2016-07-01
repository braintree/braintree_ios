#import <UIKit/UIKit.h>
#import "BTKPaymentOptionType.h"

@interface BTKPaymentOptionCardView : UIView

@property (nonatomic) BTKPaymentOptionType paymentOptionType;

- (void)setHighlighted:(BOOL)highlighted;

@end
