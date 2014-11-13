#import "BTUIPaymentMethodView.h"
#import "BTUI.h"
#import "BTUICardType.h"
#import "BTUIViewUtil.h"

#import "BTUIUnknownCardVectorArtView.h"

typedef NS_ENUM(NSInteger, BTPaymentMethodViewState) {
    BTPaymentMethodViewStateNormal,
    BTPaymentMethodViewStateProcessing,
};

@interface BTUIPaymentMethodView ()

@property (nonatomic, assign) BTPaymentMethodViewState contentState;

@property (nonatomic, strong) UIView *iconView;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *detailDescriptionLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;

@property (nonatomic, strong) NSArray *centeredLogoConstraints;
@property (nonatomic, strong) NSArray *logoEmailConstraints;

@end

@implementation BTUIPaymentMethodView

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupViews];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)setupViews {

    self.clipsToBounds = YES;

    self.iconView = [BTUIUnknownCardVectorArtView new];
    [self.iconView setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.typeLabel = [[UILabel alloc] init];
    [self.typeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.typeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.typeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    self.detailDescriptionLabel = [[UILabel alloc] init];
    [self.detailDescriptionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.detailDescriptionLabel.lineBreakMode = NSLineBreakByTruncatingMiddle; // TODO - use attributed string for line break

    // Activity Indicators
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidden = YES;
    [self.activityIndicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.topBorder = [[UIView alloc] init];
    self.topBorder.translatesAutoresizingMaskIntoConstraints = NO;

    self.bottomBorder = [[UIView alloc] init];
    self.bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.iconView];
    [self addSubview:self.typeLabel];
    [self addSubview:self.detailDescriptionLabel];
    [self addSubview:self.activityIndicatorView];
    [self addSubview:self.topBorder];
    [self addSubview:self.bottomBorder];

    // Setup initial state
    self.contentState = BTPaymentMethodViewStateNormal;

    // Setup views based on initial state
    [self updateSubviews];
    [self syncUIToTheme];
}

- (void)updateConstraints {
    [self removeConstraints:self.constraints];

    NSDictionary *views = @{ @"topBorder": self.topBorder,
                             @"bottomBorder": self.bottomBorder,
                             @"methodTypeView": self.typeLabel,
                             @"emailView": self.detailDescriptionLabel,
                             @"activityIndicatorView": self.activityIndicatorView,
                             @"iconView": self.iconView };
    NSDictionary *metrics = @{ @"logoWidth": @30,
                               @"pad": @12,
                               @"sp": @5,
                               @"activityIndicatorViewSize": @60,
                               @"iconViewHeight": @21,
                               @"borderWidth": @(self.theme.borderWidth  * 1) };

    NSLayoutConstraint *constraint;

    // Minimum height
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:40.0f];
    constraint.priority = UILayoutPriorityRequired;
    [self addConstraint:constraint];

    // Maximum height
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:60.0f];
    constraint.priority = UILayoutPriorityRequired;
    [self addConstraint:constraint];

    // Minimum width
    constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:260.0f];
    constraint.priority = UILayoutPriorityRequired;
    [self addConstraint:constraint];

    // Centered activity indicator
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[activityIndicatorView(==activityIndicatorViewSize)]" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[activityIndicatorView(==activityIndicatorViewSize)]" options:0 metrics:metrics views:views]];

    // Full Width Borders
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topBorder]|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topBorder(==borderWidth)]" options:0 metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomBorder]|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomBorder(==borderWidth)]|" options:0 metrics:metrics views:views]];

    // Icon & type
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[iconView(==iconViewHeight)]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(pad)-[iconView]-sp-[methodTypeView]"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:metrics
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[methodTypeView]-sp-[emailView]"
                                                                 options:NSLayoutFormatAlignAllBaseline
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[emailView]-(pad)-|"
                                                                 options:NSLayoutFormatAlignAllBaseline
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0.0f]];

    [super updateConstraints];
}

- (void)updateSubviews {
    switch (self.contentState) {
        case BTPaymentMethodViewStateNormal:
            self.typeLabel.text = [BTUIViewUtil nameForPaymentMethodType:self.type];

            self.detailDescriptionLabel.text = self.detailDescription;

            [self.iconView removeFromSuperview];
            self.iconView = [self.theme vectorArtViewForPaymentMethodType:self.type];
            [self.iconView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self addSubview:self.iconView];

            self.backgroundColor = [UIColor whiteColor];
            self.layer.borderColor = [self.theme borderColor].CGColor;
            self.iconView.alpha = 1.0f;
            self.typeLabel.alpha = 1.0f;
            self.detailDescriptionLabel.alpha = 1.0f;
            self.activityIndicatorView.alpha = 0.0f;
            [self.activityIndicatorView stopAnimating];
            break;
        case BTPaymentMethodViewStateProcessing:
            self.backgroundColor = [UIColor whiteColor];
            self.layer.borderColor = [self.theme borderColor].CGColor;
            self.iconView.alpha = 0.0f;
            self.typeLabel.alpha = 0.0f;
            self.detailDescriptionLabel.alpha = 0.0f;
            self.activityIndicatorView.alpha = 1.0f;
            [self.activityIndicatorView startAnimating];
            break;
        default:
            break;
    }

    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)syncUIToTheme {
  self.typeLabel.font = self.theme.controlTitleFont;
  self.typeLabel.textColor = self.theme.titleColor;
  self.detailDescriptionLabel.font = self.theme.controlDetailFont;
  self.detailDescriptionLabel.textColor = self.theme.detailColor;
  self.topBorder.backgroundColor = self.theme.borderColor;
  self.bottomBorder.backgroundColor = self.theme.borderColor;
  
  [self updateSubviews];
}



#pragma mark -

- (void)setDetailDescription:(NSString *)paymentMethodDescription {
    _detailDescription = paymentMethodDescription;
    [self updateSubviews];
}

- (void)setType:(BTUIPaymentMethodType)type {
    _type = type;
    [self updateSubviews];
}

- (void)setProcessing:(BOOL)processing {
    _processing = processing;

    self.contentState = processing ? BTPaymentMethodViewStateProcessing : BTPaymentMethodViewStateNormal;
    [UIView animateWithDuration:0.3f animations:^{
        [self updateSubviews];
    }];
}

- (void)setTheme:(BTUI *)theme {
  [super setTheme:theme];
  
  [self syncUIToTheme];
}

@end
