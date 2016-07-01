#import <UIKit/UIKit.h>
#if __has_include("BraintreeUIKit.h")
#import "BraintreeUIKit.h"
#else
#import <BraintreeUIKit/BraintreeUIKit.h>
#endif

@interface BTDropInPaymentSeletionCell : UITableViewCell

@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) BTKPaymentOptionCardView* iconView;
@property (nonatomic, strong) UIView *bottomBorder;
@property (nonatomic) BTKPaymentOptionType type;

@end
