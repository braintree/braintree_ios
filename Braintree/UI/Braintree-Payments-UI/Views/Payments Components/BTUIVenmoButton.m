#import "BTUIVenmoButton.h"

#import "BTUI.h"
#import "UIColor+BTUI.h"

@interface BTUIVenmoButton ()
@property (nonatomic, strong) UIView *venmoWordmark;
@end

@implementation BTUIVenmoButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.theme = [BTUI braintreeTheme];

    UILabel *interimLabel;
    self.venmoWordmark = interimLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    interimLabel.translatesAutoresizingMaskIntoConstraints = NO;
    interimLabel.text = @"V E N M O";
    interimLabel.textColor = [self.theme venmoPrimaryBlue];

    [self addSubview:self.venmoWordmark];
}

- (void)updateConstraints {
    NSDictionary *metrics = @{ @"minHeight": @([self.theme paymentButtonMinHeight]),
                               @"maxHeight": @([self.theme paymentButtonMaxHeight]),
                               @"required": @(UILayoutPriorityRequired) };
    NSDictionary *views = @{ @"self": self };

    // View-level constraints
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(>=minHeight@required,<=maxHeight@required)]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];

    // Venmo wordmark constraints

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeCenterX
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.venmoWordmark
                                                    attribute:NSLayoutAttributeCenterX
                                                   multiplier:1.0f
                                                      constant:0.0f]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.venmoWordmark
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [super updateConstraints];
}

@end
