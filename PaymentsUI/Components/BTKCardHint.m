#import "BTKCardHint.h"
#import "BTKViewUtil.h"
#import "BTKCVVFrontVectorArtView.h"
#import "BTKCVVBackVectorArtView.h"
#import "BTKAppearance.h"

@interface BTKCardHint ()
@property (nonatomic, strong) UIView *hintVectorArtView;
@property (nonatomic, strong) NSArray *hintVectorArtViewConstraints;
@end

@implementation BTKCardHint

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

- (void)setupView {
    self.layer.borderColor = [BTKAppearance lightGrayBorderColor].CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 2.0f;
    self.frame = CGRectMake(0, 0, 44, 28);
    self.backgroundColor = [UIColor whiteColor];
    self.hintVectorArtView = [BTKViewUtil vectorArtViewForPaymentOptionType:BTKPaymentOptionTypeUnknown];
    [self.hintVectorArtView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.hintVectorArtView];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:87.0f/55.0f
                                                      constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:44.0f]];

    [self setNeedsLayout];
}

- (void)updateConstraints {
    if (self.hintVectorArtViewConstraints) {
        [self removeConstraints:self.hintVectorArtViewConstraints];
    }
    
    NSDictionary* viewBindings = @{@"view":self, @"hintVectorArtView":self.hintVectorArtView};

    NSMutableArray* layoutConstraints = [NSMutableArray array];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[hintVectorArtView]|"
                                                                                        options:0
                                                                                        metrics:nil
                                                                                          views:viewBindings]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hintVectorArtView]|"
                                                                                        options:0
                                                                                        metrics:nil
                                                                                          views:viewBindings]];

    self.hintVectorArtViewConstraints = [layoutConstraints copy];
    [self addConstraints:self.hintVectorArtViewConstraints];

    [super updateConstraints];
}

- (void)updateViews {
    UIView *cardVectorArtView;
    switch (self.displayMode) {
        case BTKCardHintDisplayModeCardType:
            cardVectorArtView = [BTKViewUtil vectorArtViewForPaymentOptionType:self.cardType];
            break;
        case BTKCardHintDisplayModeCVVHint:
            if (self.cardType == BTKPaymentOptionTypeAMEX) {
                cardVectorArtView = [BTKCVVFrontVectorArtView new];
            } else {
                cardVectorArtView = [BTKCVVBackVectorArtView new];
            }
            break;
    }

    [self.hintVectorArtView removeFromSuperview];
    self.hintVectorArtView = cardVectorArtView;
    [self.hintVectorArtView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.hintVectorArtView];
    [self setHighlighted:self.highlighted];
    
    if (self.cardType == BTKPaymentOptionTypeApplePay) {
        self.layer.borderWidth = 0.0f;
        self.layer.cornerRadius = 0.0f;
        self.backgroundColor = [UIColor clearColor];
    } else {
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 2.0f;
        self.backgroundColor = [UIColor whiteColor];
    }

    [self setNeedsUpdateConstraints];
    [self updateConstraints];
    [self setNeedsLayout];
}

- (void)setCardType:(BTKPaymentOptionType)cardType {
    _cardType = cardType;
    [self updateViews];
}

- (void)setCardType:(BTKPaymentOptionType)cardType animated:(BOOL)animated {
    if (cardType == self.cardType) {
        return;
    }
    if (animated) {
        [UIView transitionWithView:self
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self setCardType:cardType];
                        } completion:nil];
    } else {
        [self setCardType:cardType];
    }
}

- (void)setDisplayMode:(BTKCardHintDisplayMode)displayMode {
    _displayMode = displayMode;
    [self updateViews];
}

- (void)setDisplayMode:(BTKCardHintDisplayMode)displayMode animated:(BOOL)animated {
    if (animated) {
        [UIView transitionWithView:self
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            [self setDisplayMode:displayMode];
                        } completion:nil];
    } else {
        [self updateViews];
    }
}

#pragma mark - Highlighting

- (void)setHighlighted:(BOOL)highlighted {
    [self setHighlighted:highlighted animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    _highlighted = highlighted;
    UIColor *c = highlighted ? self.tintColor : nil;
    [self setHighlightColor:c animated:animated];
}

- (void)setHighlightColor:(UIColor *)color animated:(BOOL)animated {
    if (![self.hintVectorArtView respondsToSelector:@selector(setHighlightColor:)]) {
        return;
    }
    if (animated) {
        [UIView transitionWithView:self.hintVectorArtView
                          duration:0.1f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.hintVectorArtView performSelector:@selector(setHighlightColor:) withObject:color];
                            [self.hintVectorArtView setNeedsDisplay];
                        }
                        completion:nil
         ];
    } else {
        [self.hintVectorArtView performSelector:@selector(setHighlightColor:) withObject:color];
        [self.hintVectorArtView setNeedsDisplay];
    }
}

- (void)tintColorDidChange {
    [self setHighlighted:self.highlighted animated:YES];
}

@end
