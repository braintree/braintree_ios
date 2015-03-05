#import "BTUICoinbaseButton.h"

#import "BTUI.h"
#import "UIColor+BTUI.h"

#import "BTUICoinbaseWordmarkVectorArtView.h"

@interface BTUICoinbaseButton ()
@property (nonatomic, strong) BTUICoinbaseWordmarkVectorArtView *coinbaseWordmark;
@end

@implementation BTUICoinbaseButton

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
    self.backgroundColor = [UIColor whiteColor];

    self.coinbaseWordmark = [[BTUICoinbaseWordmarkVectorArtView alloc] init];
    self.coinbaseWordmark.userInteractionEnabled = NO;
    self.coinbaseWordmark.translatesAutoresizingMaskIntoConstraints = NO;
    self.coinbaseWordmark.color = [self.theme coinbasePrimaryBlue];

    [self addSubview:self.coinbaseWordmark];
}

- (void)updateConstraints {
    NSDictionary *metrics = @{ @"minHeight": @([self.theme paymentButtonMinHeight]),
                               @"maxHeight": @([self.theme paymentButtonMaxHeight]),
                               @"wordMarkHeight": @([self.theme paymentButtonWordMarkHeight]),
                               @"minWidth": @(200),
                               @"required": @(UILayoutPriorityRequired),
                               @"high": @(UILayoutPriorityDefaultHigh),
                               @"breathingRoom": @(10) };
    NSDictionary *views = @{ @"self": self ,
                             @"coinbaseWordmark": self.coinbaseWordmark };

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[coinbaseWordmark(wordMarkHeight)]"
                                            options:0
                                            metrics:metrics
                                              views:views]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeCenterX
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.coinbaseWordmark
                                                    attribute:NSLayoutAttributeCenterX
                                                   multiplier:1.0f
                                                      constant:0.0f]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.coinbaseWordmark
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:-1.5f]];

    [super updateConstraints];
}

- (void)setHighlighted:(BOOL)highlighted {
    [UIView animateWithDuration:0.08f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                            if (highlighted) {
                                self.backgroundColor = [UIColor colorWithWhite:0.92f alpha:1.0f];
                            } else {
                                self.backgroundColor = [UIColor whiteColor];
                            }
                        }
                     completion:nil];
}

@end
