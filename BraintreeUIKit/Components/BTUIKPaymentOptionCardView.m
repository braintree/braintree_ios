#import "BTUIKPaymentOptionCardView.h"
#import "BTUIKViewUtil.h"
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
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 4;
        self.layer.borderColor = [BTUIKAppearance grayBorderColor].CGColor;
        self.layer.borderWidth = 1.0;
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
    
    NSDictionary* viewBindings = @{@"imageView":self.imageView};
    
    NSDictionary* metrics = @{@"PADDING": self.paymentOptionType == BTUIKPaymentOptionTypeApplePay ? @0 : @3};

    self.layer.borderWidth = self.paymentOptionType == BTUIKPaymentOptionTypeApplePay ? 0.0 : 1.0;
    
    self.backgroundColor = self.paymentOptionType == BTUIKPaymentOptionTypeApplePay ? [UIColor clearColor] : [UIColor whiteColor];


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
    self.imageView = [BTUIKViewUtil vectorArtViewForPaymentOptionType:self.paymentOptionType];
}

- (void)setHighlighted:(BOOL)highlighted {
    if (self.paymentOptionType == BTUIKPaymentOptionTypeApplePay) {
        return;
    }
    if (highlighted) {
        self.layer.borderColor = self.tintColor.CGColor;
        self.layer.borderWidth = 2.0f;
    } else {
        self.layer.borderColor = [BTUIKAppearance grayBorderColor].CGColor;
        self.layer.borderWidth = 1.0f;
    }
}

- (CGSize)getArtDimensions {
    return self.imageView.artDimensions;
}

@end
