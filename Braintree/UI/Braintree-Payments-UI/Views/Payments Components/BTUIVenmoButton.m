#import "BTUIVenmoButton.h"

#import "BTUI.h"
#import "UIColor+BTUI.h"

#import "BTUIVenmoWordmarkVectorArtView.h"

@interface BTUIVenmoButton ()
@property (nonatomic, strong) BTUIVenmoWordmarkVectorArtView *venmoWordmark;
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
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];

    self.venmoWordmark = [[BTUIVenmoWordmarkVectorArtView alloc] init];
    self.venmoWordmark.userInteractionEnabled = NO;
    self.venmoWordmark.translatesAutoresizingMaskIntoConstraints = NO;
    self.venmoWordmark.color = [self.theme venmoPrimaryBlue];

    [self addSubview:self.venmoWordmark];
}

- (void)updateConstraints {
    NSDictionary *metrics = @{ @"minHeight": @([self.theme paymentButtonMinHeight]),
                               @"maxHeight": @([self.theme paymentButtonMaxHeight]),
                               @"minWidth": @(200),
                               @"required": @(UILayoutPriorityRequired),
                               @"high": @(UILayoutPriorityDefaultHigh),
                               @"breathingRoom": @(10) };
    NSDictionary *views = @{ @"self": self ,
                             @"venmoWordmark": self.venmoWordmark };

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[self(>=minWidth)]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(>=minHeight@required,<=maxHeight@required)]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];

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

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=breathingRoom@required)-[venmoWordmark]-(>=breathingRoom@required)-|"
                                            options:0
                                            metrics:metrics
                                              views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=breathingRoom@required)-[venmoWordmark]-(>=breathingRoom@required)-|"
                                            options:0
                                            metrics:metrics
                                              views:views]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                        toItem:self.venmoWordmark
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0f
                                                      constant:0.0f]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                        toItem:self.venmoWordmark
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.20f
                                                      constant:0.0f]];
    [super updateConstraints];
}

- (void)setHighlighted:(BOOL)highlighted {
    [UIView animateWithDuration:0.08f animations:^{
        if (highlighted) {
            self.venmoWordmark.alpha = 0.3;
        } else {
            self.venmoWordmark.alpha = 1.0f;
        }
    }];
}

@end
