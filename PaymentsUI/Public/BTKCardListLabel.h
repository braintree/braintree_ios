#import <UIKit/UIKit.h>
#import "BTKPaymentOptionType.h"

@interface BTKCardListLabel : UILabel

@property (nonatomic, copy) NSArray* availablePaymentOptions;

- (void)emphasizePaymentOption:(BTKPaymentOptionType)paymentOption;

@end
