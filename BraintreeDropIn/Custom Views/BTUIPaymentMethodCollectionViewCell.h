#import <UIKit/UIKit.h>
#import "BTPaymentMethodNonce.h"

@class BTKPaymentOptionCardView;

@interface BTUIPaymentMethodCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) BTKPaymentOptionCardView* paymentOptionCardView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) BTPaymentMethodNonce* paymentMethodNonce;

@end
