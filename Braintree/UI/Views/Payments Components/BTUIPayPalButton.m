#import "BTUIPayPalButton.h"

#import "BTUIPayPalWordmarkVectorArtView.h"

#import "BTUI.h"

@interface BTUIPayPalButton ()
@property (nonatomic, strong) BTUIPayPalWordmarkVectorArtView *payPalWordmark;
@end

@implementation BTUIPayPalButton

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

    self.payPalWordmark = [[BTUIPayPalWordmarkVectorArtView alloc] initWithPadding];
    self.payPalWordmark.userInteractionEnabled = NO;
    self.payPalWordmark.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.payPalWordmark];
}

- (void)updateConstraints {
    NSDictionary *metrics = @{ @"minHeight": @([self.theme paymentButtonMinHeight]),
                               @"maxHeight": @([self.theme paymentButtonMaxHeight]),
                               @"minWidth": @(200),
                               @"required": @(UILayoutPriorityRequired),
                               @"high": @(UILayoutPriorityDefaultHigh),
                               @"breathingRoom": @(10) };
    NSDictionary *views = @{ @"self": self ,
                             @"payPalWordmark": self.payPalWordmark };

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[payPalWordmark]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeCenterX
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.payPalWordmark
                                                    attribute:NSLayoutAttributeCenterX
                                                   multiplier:1.0f
                                                      constant:0.0f]];

    [super updateConstraints];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 44);
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
