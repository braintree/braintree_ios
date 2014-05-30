#import "BTPayPalControlContentView.h"
#import "BTUIPayPalMonogramColorView.h"
#import "BTPayPalHorizontalSignatureWhiteView.h"

#import "BTUI.h"

@interface BTPayPalControlContentView ()

@property (nonatomic, strong) UIView *payPalHorizontalSignatureView;
@end

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

- (void)setupViews {
    self.userInteractionEnabled = NO;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5.0f;
    self.layer.borderWidth = 0.5f;

    self.payPalHorizontalSignatureView = [[BTPayPalHorizontalSignatureWhiteView alloc] init];
    [self.payPalHorizontalSignatureView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self addSubview:self.payPalHorizontalSignatureView];


    self.backgroundColor = [[BTUI braintreeTheme]  payPalButtonBlue];
    self.layer.borderColor = [UIColor clearColor].CGColor;


    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0f
                                                         constant:0],

                           [NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0f
                                                         constant:0],

                           [NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:95],

                           [NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:23]]];

    NSLayoutConstraint *constraint;

    // Minimum height
    constraint = [NSLayoutConstraint constraintWithItem:self
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0f
                                               constant:40.0f];
    constraint.priority = UILayoutPriorityRequired;
    [self addConstraint:constraint];

    // Maximum height
    constraint = [NSLayoutConstraint constraintWithItem:self
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0f
                                               constant:60.0f];
    constraint.priority = UILayoutPriorityRequired;
    [self addConstraint:constraint];

    // Minimum width
    constraint = [NSLayoutConstraint constraintWithItem:self
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0f
                                               constant:260.0f];
    constraint.priority = UILayoutPriorityRequired;
    [self addConstraint:constraint];
}

#pragma mark -

- (void)setHighlighted:(BOOL)highlighted {
    [UIView animateWithDuration:0.08f animations:^{
        self.backgroundColor = highlighted ? [[BTUI braintreeTheme]  payPalButtonActiveBlue] : [[BTUI braintreeTheme]  payPalButtonBlue];
    }];
}

@end
