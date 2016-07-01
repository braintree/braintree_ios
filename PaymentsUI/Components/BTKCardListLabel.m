#import "BTKCardListLabel.h"
#import "BTKCardHint.h"
#import <QuartzCore/QuartzCore.h>

@interface BTKCardListLabel ()

@property (nonatomic, strong) NSArray *allPaymentOptions;
@property (nonatomic, strong) NSArray *availablePaymentOptionAttachments;
@property (nonatomic) BTKPaymentOptionType emphasisedPaymentOption;

@end

@implementation BTKCardListLabel


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfLines = 0;
        self.textAlignment = NSTextAlignmentCenter;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.emphasisedPaymentOption = BTKPaymentOptionTypeUnknown;
        self.availablePaymentOptionAttachments = @[];

        self.allPaymentOptions = @[@(BTKPaymentOptionTypeVisa), @(BTKPaymentOptionTypeMasterCard), @(BTKPaymentOptionTypeDiscover), @(BTKPaymentOptionTypeAMEX),@(BTKPaymentOptionTypeDinersClub), @(BTKPaymentOptionTypeUnionPay), @(BTKPaymentOptionTypeJCB), @(BTKPaymentOptionTypeMaestro)];

        self.availablePaymentOptions = self.allPaymentOptions;
    }
    return self;
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)setAvailablePaymentOptions:(NSArray *)availablePaymentOptions {
    _availablePaymentOptions = availablePaymentOptions;
    [self updateAppearance];
    [self emphasizePaymentOption:self.emphasisedPaymentOption];
}

- (void)updateAppearance {
    NSMutableAttributedString *at = [[NSMutableAttributedString alloc] initWithString:@""];
    NSMutableArray *attachments = [NSMutableArray new];
    BTKCardHint* hint = [BTKCardHint new];
    hint.translatesAutoresizingMaskIntoConstraints = NO;
    hint.displayMode = BTKCardHintDisplayModeCardType;

    for(NSNumber *paymentType in self.allPaymentOptions) {
        NSTextAttachment *composeAttachment = [NSTextAttachment new];
        BTKPaymentOptionType paymentOption = ((NSNumber*)paymentType).intValue;
        [hint setCardType:paymentOption];
        [hint layoutIfNeeded];
        UIImage* composeImage = [self imageWithView:hint];
        [attachments addObject:composeAttachment];
        composeAttachment.image = composeImage;
        [at appendAttributedString:[NSAttributedString attributedStringWithAttachment:composeAttachment]];
        [at appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" "]];
        
    }
    self.attributedText = at;
    self.availablePaymentOptionAttachments = attachments;
}

- (void)emphasizePaymentOption:(BTKPaymentOptionType)paymentOption
{
    if (paymentOption == self.emphasisedPaymentOption) {
        return;
    }
    
    [self updateAppearance];
    for (NSUInteger i = 0; i < self.availablePaymentOptions.count; i++) {
        BTKPaymentOptionType option = ((NSNumber*)self.availablePaymentOptions[i]).intValue;
        float newAlpha = (paymentOption == option || paymentOption == BTKPaymentOptionTypeUnknown) ? 1.0 : 0.25;
        NSTextAttachment *attachment = self.availablePaymentOptionAttachments[i];
        UIGraphicsBeginImageContextWithOptions(attachment.image.size, NO, attachment.image.scale);
        [attachment.image drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:newAlpha];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        attachment.image = image;
    }
    self.emphasisedPaymentOption = paymentOption;
    [self setNeedsDisplay];
}


@end
