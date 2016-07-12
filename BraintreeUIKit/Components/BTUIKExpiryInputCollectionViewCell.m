#import "BTUIKExpiryInputCollectionViewCell.h"
#import "UIColor+BTUIK.h"

@implementation BTUIKExpiryInputCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        self.label.font = [UIFont systemFontOfSize:24];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.label];
        
        UIView* bgView = [[UIView alloc] initWithFrame:self.frame];
        bgView.layer.cornerRadius = 4;
        self.selectedBackgroundView = bgView;
        self.selectedBackgroundView.backgroundColor = [UIColor btuik_colorFromHex:@"D1D4D9" alpha:1.0];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"label":self.label}]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"label":self.label}]];
        
    }
    return self;
}

- (NSInteger)getInteger {
    return [self.label.text integerValue];
}

@end
