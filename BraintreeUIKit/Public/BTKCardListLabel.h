#import <UIKit/UIKit.h>
#import "BTKPaymentOptionType.h"

/// @class A UILabel that contains images representing multiple BTKPaymentOptionType's
@interface BTKCardListLabel : UILabel

/// The array of BTKPaymentOptionType's to display
@property (nonatomic, copy) NSArray* availablePaymentOptions;

/// The BTKPaymentOptionType to emphasize by fading all other payment methods included in availablePaymentOptions
- (void)emphasizePaymentOption:(BTKPaymentOptionType)paymentOption;

@end
