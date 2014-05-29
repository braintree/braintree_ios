#import "BTPayPalControlContentView_Internal.h"
#import "BTUIPayPalMonogramColorView.h"
#import "BTPayPalHorizontalSignatureWhiteView.h"

#import "BTUI.h"

@implementation BTPayPalControlContentView

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self setupViews];
    }
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
    if (self != nil) {
        [self setupViews];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)setupViews {
    self.userInteractionEnabled = NO;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5.0f;
    self.layer.borderWidth = 0.5f;

    // Pay with PayPal
    self.payWithPayPalView = [[UIView alloc] init];
    self.payWithPayPalView.translatesAutoresizingMaskIntoConstraints = NO;

    // Make payWithPayPalView the exact size of its content
    [self.payWithPayPalView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.payWithPayPalView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.payWithPayPalView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.payWithPayPalView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];


    UIView *logoView = [[BTPayPalHorizontalSignatureWhiteView alloc] init];
    logoView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.payWithPayPalView addSubview:logoView];

    [self.payWithPayPalView addConstraint:[NSLayoutConstraint constraintWithItem:logoView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.payWithPayPalView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0f
                                                                        constant:0]];

    [self.payWithPayPalView addConstraint:[NSLayoutConstraint constraintWithItem:logoView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.payWithPayPalView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0f
                                                                        constant:0]];


    [self.payWithPayPalView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[logo(95)]-|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:@{@"logo": logoView}]];

    [self.payWithPayPalView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[logo(23)]-|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:@{@"logo": logoView}]];



    [self addSubview:self.payWithPayPalView];

    [self updateSubviews];
}

- (void)updateConstraints {
    [self removeConstraints:self.constraints];

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


    // Centered wordmark logo

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.payWithPayPalView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.payWithPayPalView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];

    [super updateConstraints];
}

- (void)updateSubviews {
    self.backgroundColor = [[BTUI braintreeTheme]  payPalButtonBlue];
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.payWithPayPalView.alpha = 1.0f;
}

#pragma mark -

- (void)setHighlighted:(BOOL)highlighted {
    [UIView animateWithDuration:0.08f animations:^{
        self.backgroundColor = highlighted ? [[BTUI braintreeTheme]  payPalButtonActiveBlue] : [[BTUI braintreeTheme]  payPalButtonBlue];
    }];
}

@end
