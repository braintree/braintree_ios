#import "BTDropInPaymentSeletionCell.h"
#import "UIColor+BTUIK.h"

@interface BTDropInPaymentSeletionCell()

@end

@implementation BTDropInPaymentSeletionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = NO;

        [self.contentView removeConstraints:self.contentView.constraints];
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

        self.label = [[UILabel alloc] init];
        [BTUIKAppearance styleLabelPrimary:self.label];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.label];

        self.iconView = [BTUIKPaymentOptionCardView new];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.iconView];
        self.backgroundColor = [UIColor clearColor];

        self.bottomBorder = [UIView new];
        self.bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        self.bottomBorder.backgroundColor = [BTUIKAppearance sharedInstance].lineColor;
        [self.contentView addSubview:self.bottomBorder];
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = [[BTUIKAppearance sharedInstance].sheetBackgroundColor BTUIK_adjustedBrightness:0.8];
        self.selectedBackgroundView = backgroundView;
        [self applyConstraints];

    }
    return self;
}

- (void)applyConstraints {
    [self removeConstraints:self.constraints];
    [self.contentView removeConstraints:self.contentView.constraints];
    [self.label removeConstraints:self.label.constraints];
    NSDictionary* viewBindings = @{@"contentView":self.contentView, @"label":self.label, @"iconView":self.iconView, @"bottomBorder":self.bottomBorder};

    NSDictionary* metrics = @{@"PADDING":@10};

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:viewBindings]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:viewBindings]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label][bottomBorder(1)]|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewBindings]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[bottomBorder(label)]|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewBindings]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0f]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[iconView(50)]-[label]|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewBindings]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[iconView(32)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewBindings]];
}

@end
