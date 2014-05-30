#import "BTUICTAControl.h"
#import "BTUI.h"

@interface BTUICTAControl()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
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
    self.theme = [BTUI braintreeTheme];

    self.label = [[UILabel alloc] init];
    [self.label setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.label.textColor = [UIColor whiteColor];
    self.label.font = [UIFont systemFontOfSize:17.0f];
    self.label.textAlignment = NSTextAlignmentCenter;

    [self addSubview:self.label];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.activityIndicator];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];

    [self updateText];
}

- (void)showLoadingState: (__unused BOOL)loadingState{
    if (loadingState) {
        self.label.hidden = YES;
        [self.activityIndicator startAnimating];
    } else {
        self.label.hidden = NO;
        [self.activityIndicator stopAnimating];
    }
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

- (void)setTheme:(BTUI *)theme {
    _theme = theme;
    self.backgroundColor = theme.callToActionColor;
}

#pragma mark Highlight Presentation

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setBackgroundColor:highlighted ? [UIColor colorWithRed:0.375 green:0.635 blue:0.984 alpha:1.000] : self.theme.callToActionColor];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self setBackgroundColor:enabled ? self.theme.callToActionColor : self.theme.disabledButtonColor];
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
