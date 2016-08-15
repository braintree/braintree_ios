#import "BTUIKPaymentOptionCardView.h"
#import "BTUIKVectorArtView.h"
#import "BTUIKAppearance.h"

@interface BTUIKPaymentOptionCardView()

@property (nonatomic, strong) BTUIKVectorArtView* imageView;

@end

@implementation BTUIKPaymentOptionCardView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.vectorArtSize = BTUIKVectorArtSizeRegular;
        self.cornerRadius = 4.0;
        self.innerPadding = 0.0;
        self.borderWidth = 0.5;
        self.borderColor = [BTUIKAppearance sharedInstance].lineColor;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setImageView:(BTUIKVectorArtView *)imageView {
    if (self.imageView) {
        [self.imageView removeFromSuperview];
    }
    _imageView = imageView;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.imageView];
    [self updateAppearance];
}

- (void)updateAppearance {
    NSDictionary* viewBindings = @{@"imageView":self.imageView};
    
    NSDictionary* metrics = @{@"PADDING": @(self.innerPadding)};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(PADDING)-[imageView]-(PADDING)-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:viewBindings]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.imageView
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:self.imageView.artDimensions.height/self.imageView.artDimensions.width
                                                      constant:0]];
}

- (void)setPaymentOptionType:(BTUIKPaymentOptionType)paymentOptionType {
    _paymentOptionType = paymentOptionType;
    self.borderWidth = self.paymentOptionType == BTUIKPaymentOptionTypeApplePay ? 0.0 : self.borderWidth;
    self.imageView = [BTUIKViewUtil vectorArtViewForPaymentOptionType:self.paymentOptionType size:self.vectorArtSize];
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.layer.borderColor = self.tintColor.CGColor;
    } else {
        self.layer.borderColor = self.borderColor.CGColor;
    }
}

- (CGSize)getArtDimensions {
    return self.imageView.artDimensions;
}

- (void)setCornerRadius:(float)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = self.cornerRadius;
}

- (void)setBorderWidth:(float)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = _borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = _borderColor.CGColor;
}

- (void)setInnerPadding:(float)innerPadding {
    _innerPadding = innerPadding;
    if (self.imageView != nil) {
        [self updateAppearance];
    }
}

@end
