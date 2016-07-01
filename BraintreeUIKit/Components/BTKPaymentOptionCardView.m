#import "BTKPaymentOptionCardView.h"
#import "BTKViewUtil.h"
#import "BTKVectorArtView.h"
#import "BTKAppearance.h"

@interface BTKPaymentOptionCardView()

@property (nonatomic, strong) BTKVectorArtView* imageView;

@end

@implementation BTKPaymentOptionCardView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 4;
        self.layer.borderColor = [BTKAppearance grayBorderColor].CGColor;
        self.layer.borderWidth = 1.0;
    }
    return self;
}

- (void)setImageView:(BTKVectorArtView *)imageView {
    if (self.imageView) {
        [self.imageView removeFromSuperview];
    }
    _imageView = imageView;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.imageView];
    
    NSDictionary* viewBindings = @{@"imageView":self.imageView};
    
    NSDictionary* metrics = @{@"PADDING": self.paymentOptionType == BTKPaymentOptionTypeApplePay ? @0 : @3};

    self.layer.borderWidth = self.paymentOptionType == BTKPaymentOptionTypeApplePay ? 0.0 : 1.0;
    
    self.backgroundColor = self.paymentOptionType == BTKPaymentOptionTypeApplePay ? [UIColor clearColor] : [UIColor whiteColor];


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

- (void)setPaymentOptionType:(BTKPaymentOptionType)paymentOptionType {
    _paymentOptionType = paymentOptionType;
    self.imageView = [BTKViewUtil vectorArtViewForPaymentOptionType:self.paymentOptionType];
}

- (void)setHighlighted:(BOOL)highlighted {
    if (self.paymentOptionType == BTKPaymentOptionTypeApplePay) {
        return;
    }
    if (highlighted) {
        self.layer.borderColor = self.tintColor.CGColor;
        self.layer.borderWidth = 2.0f;
    } else {
        self.layer.borderColor = [BTKAppearance grayBorderColor].CGColor;
        self.layer.borderWidth = 1.0f;
    }
}

- (CGSize)getArtDimensions {
    return self.imageView.artDimensions;
}

@end
