#import "BTUICTAControl.h"
#import "BTUI.h"

@interface BTUICTAControl()
@property (nonatomic, strong) UILabel *label;
@end

@implementation BTUICTAControl

- (id)initWithFrame:(CGRect)frame {
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

#pragma mark View Lifecycle

- (void)setupView {
    self.backgroundColor = [[BTUI braintreeTheme] callToActionColor];

    self.label = [[UILabel alloc] init];
    [self.label setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.label.textColor = [UIColor whiteColor];
    self.label.font = [UIFont systemFontOfSize:17.0f];
    self.label.textAlignment = NSTextAlignmentCenter;

    [self addSubview:self.label];

    [self updateText];
}

- (void)updateConstraints {
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.label
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0f
                                                         constant:0.0f],

                           [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.label
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0f
                                                         constant:0.0f],

                           [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.label
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0f
                                                         constant:0.0f],

                           [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.label
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0f
                                                         constant:0.0f],
                           ]];
    [super updateConstraints];
}

#pragma mark Highlight Presentation

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setBackgroundColor:highlighted ? [UIColor colorWithRed:0.375 green:0.635 blue:0.984 alpha:1.000] : [[BTUI braintreeTheme] callToActionColor]];
}
#pragma mark Public Parameters

- (void)setAmount:(NSString *)amount {
    _amount = amount;
    [self updateText];
}

- (void)setCallToAction:(NSString *)callToAction {
    _callToAction = callToAction;
    [self updateText];
}

#pragma mark State Management

- (void)updateText {
    if (self.amount) {
        self.label.text = [NSString stringWithFormat:@"%@ - %@", self.amount, self.callToAction];
    } else {
        self.label.text = [NSString stringWithFormat:@"%@", self.callToAction];
    }
}

@end
