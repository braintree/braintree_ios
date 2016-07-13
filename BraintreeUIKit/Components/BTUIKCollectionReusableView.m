#import "BTUIKCollectionReusableView.h"
#import "UIColor+BTUIK.h"

@implementation BTUIKCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] init];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:12];
        self.label.textColor = [UIColor btuik_colorFromHex:@"666666" alpha:1.0];
        [self addSubview:self.label];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"label":self.label}]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"label":self.label}]];
        
    }
    return self;
}

@end
