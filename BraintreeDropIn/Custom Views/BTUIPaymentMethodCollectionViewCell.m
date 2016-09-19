#import "BTUIPaymentMethodCollectionViewCell.h"
#import "BTUIKPaymentOptionCardView.h"
#import "BTUIKAppearance.h"

#define LARGE_ICON_INNER_PADDING 10.0
#define LARGE_ICON_CORNER_RADIUS 20.0

@implementation BTUIPaymentMethodCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self removeConstraints:self.constraints];
        [self.contentView removeConstraints:self.contentView.constraints];
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

        self.paymentOptionCardView = [[BTUIKPaymentOptionCardView alloc] init];
        self.paymentOptionCardView.translatesAutoresizingMaskIntoConstraints = NO;
        self.paymentOptionCardView.innerPadding = LARGE_ICON_INNER_PADDING;
        self.paymentOptionCardView.vectorArtSize = BTUIKVectorArtSizeLarge;
        self.paymentOptionCardView.cornerRadius = LARGE_ICON_CORNER_RADIUS;
        self.paymentOptionCardView.borderColor = [UIColor whiteColor];
        
        self.paymentOptionCardView.layer.masksToBounds = NO;
        self.paymentOptionCardView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.paymentOptionCardView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.paymentOptionCardView.layer.shadowOpacity = 0.12f;
        self.paymentOptionCardView.layer.shadowRadius = 5.0f;
        
        [self.contentView addSubview:self.paymentOptionCardView];

        self.titleLabel = [[UILabel alloc] init];
        [BTUIKAppearance styleSmallLabelBoldPrimary:self.titleLabel];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"";
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
        
        self.descriptionLabel = [[UILabel alloc] init];
        [BTUIKAppearance styleLabelSecondary:self.descriptionLabel];
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.descriptionLabel.text = @"";
        self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.descriptionLabel];

        NSDictionary* viewBindings = @{@"contentView":self.contentView, @"paymentOptionCardView":self.paymentOptionCardView, @"titleLabel":self.titleLabel,
            @"descriptionLabel":self.descriptionLabel};

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                                                     options:0
                                                                     metrics:[BTUIKAppearance metrics]
                                                                       views:viewBindings]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                                                     options:0
                                                                     metrics:[BTUIKAppearance metrics]
                                                                       views:viewBindings]];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[paymentOptionCardView(LARGE_ICON_WIDTH)]"
                                                                                 options:0
                                                                                 metrics:[BTUIKAppearance metrics]
                                                                                   views:viewBindings]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel]|"
                                                                                 options:0
                                                                                 metrics:[BTUIKAppearance metrics]
                                                                                   views:viewBindings]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[descriptionLabel]|"
                                                                                 options:0
                                                                                 metrics:[BTUIKAppearance metrics]
                                                                                   views:viewBindings]];
        
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[paymentOptionCardView(LARGE_ICON_HEIGHT)]-(HORIZONTAL_FORM_PADDING)-[titleLabel][descriptionLabel]-(>=1)-|"
                                                                                 options:0
                                                                                 metrics:[BTUIKAppearance metrics]
                                                                                   views:viewBindings]];
        [self.paymentOptionCardView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    }
    return self;
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? 0.5 : 1.0;
}

@end
