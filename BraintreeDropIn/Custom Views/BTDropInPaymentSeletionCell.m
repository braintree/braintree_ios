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
        backgroundView.backgroundColor = [[BTUIKAppearance sharedInstance].formBackgroundColor btuik_adjustedBrightness:0.8];
        self.selectedBackgroundView = backgroundView;
        self.backgroundView = nil;
        [self applyConstraints];

    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    UIColor *backgroundColor = self.iconView.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.iconView.backgroundColor = backgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIColor *backgroundColor = self.iconView.backgroundColor;
    [super setSelected:selected animated:animated];
    self.iconView.backgroundColor = backgroundColor;
}

- (void)applyConstraints {
    [self removeConstraints:self.constraints];
    [self.contentView removeConstraints:self.contentView.constraints];
    [self.label removeConstraints:self.label.constraints];
    NSDictionary* viewBindings = @{@"contentView":self.contentView, @"label":self.label, @"iconView":self.iconView, @"bottomBorder":self.bottomBorder};

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                                                 options:0
                                                                 metrics:[BTUIKAppearance metrics]
                                                                   views:viewBindings]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                                                 options:0
                                                                 metrics:[BTUIKAppearance metrics]
                                                                   views:viewBindings]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label][bottomBorder(0.5)]|"
                                                                             options:0
                                                                             metrics:[BTUIKAppearance metrics]
                                                                               views:viewBindings]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[bottomBorder(label)]|"
                                                                             options:0
                                                                             metrics:[BTUIKAppearance metrics]
                                                                               views:viewBindings]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0f]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(HORIZONTAL_FORM_PADDING)-[iconView(ICON_WIDTH)]-(HORIZONTAL_FORM_PADDING)-[label]|"
                                                                             options:0
                                                                             metrics:[BTUIKAppearance metrics]
                                                                               views:viewBindings]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[iconView(ICON_HEIGHT)]"
                                                                             options:0
                                                                             metrics:[BTUIKAppearance metrics]
                                                                               views:viewBindings]];
}

@end
