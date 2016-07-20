#import "BTUIKCardListLabel.h"
#import "BTUIKCardHint.h"
#import "BTUIKViewUtil.h"
#import <QuartzCore/QuartzCore.h>

@interface BTUIKCardListLabel ()

@property (nonatomic, strong) NSArray *availablePaymentOptionAttachments;
@property (nonatomic) BTUIKPaymentOptionType emphasisedPaymentOption;

@end

@implementation BTUIKCardListLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfLines = 0;
        self.textAlignment = NSTextAlignmentCenter;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.emphasisedPaymentOption = BTUIKPaymentOptionTypeUnknown;
        self.availablePaymentOptionAttachments = @[];

        self.availablePaymentOptions = @[];
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
    if ([BTUIKViewUtil isLanguageLayoutDirectionRightToLeft]) {
        _availablePaymentOptions = [[_availablePaymentOptions reverseObjectEnumerator] allObjects];
    }
    [self updateAppearance];
    [self emphasizePaymentOption:self.emphasisedPaymentOption];
}

- (void)updateAppearance {
    NSMutableAttributedString *at = [[NSMutableAttributedString alloc] initWithString:@""];
    NSMutableArray *attachments = [NSMutableArray new];
    BTUIKCardHint* hint = [BTUIKCardHint new];
    hint.translatesAutoresizingMaskIntoConstraints = NO;
    hint.displayMode = BTUIKCardHintDisplayModeCardType;
    
    for(NSNumber *paymentType in self.availablePaymentOptions) {
        NSTextAttachment *composeAttachment = [NSTextAttachment new];
        BTUIKPaymentOptionType paymentOption = ((NSNumber*)paymentType).intValue;
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

- (void)emphasizePaymentOption:(BTUIKPaymentOptionType)paymentOption
{
    if (paymentOption == self.emphasisedPaymentOption) {
        return;
    }
    
    [self updateAppearance];
    for (NSUInteger i = 0; i < self.availablePaymentOptions.count; i++) {
        BTUIKPaymentOptionType option = ((NSNumber*)self.availablePaymentOptions[i]).intValue;
        float newAlpha = (paymentOption == option || paymentOption == BTUIKPaymentOptionTypeUnknown) ? 1.0 : 0.25;
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
