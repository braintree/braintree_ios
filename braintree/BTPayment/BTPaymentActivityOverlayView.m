#import <QuartzCore/CALayer.h>
#import "BTPaymentActivityOverlayView.h"

static BTPaymentActivityOverlayView *sharedOverlayView = nil;

@interface BTPaymentActivityOverlayView ()
- (id)initWithTitle:(NSString *)title;
@end

@implementation BTPaymentActivityOverlayView

#pragma mark - Properties

- (UIActivityIndicatorView *)activityIndicatorView {
    return (UIActivityIndicatorView *)[self viewWithTag:1];
}

- (UILabel *)titleLabel {
    return (UILabel *)[self viewWithTag:2];
}

#pragma mark - Initializers

// Global Accessor
+ (id)sharedOverlayView {
    if (!sharedOverlayView) {
        sharedOverlayView = [[BTPaymentActivityOverlayView alloc] initWithTitle:@"Loading..."];
    }
    return sharedOverlayView;
}

// Designated Initializer @private
- (id)initWithTitle:(NSString *)title {
    CGRect frame = CGRectMake(74.0f, 154.0f, 172.0f, 172.0f);
    if ((self = [super initWithFrame:frame])) {
        self.hidden = YES;
        self.autoresizingMask = // keep centered during rotation
        (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
         UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f]; // translucent black
        self.layer.cornerRadius = 10.0f;

        CGPoint centerPoint = CGPointMake(86, 86);

        UIActivityIndicatorView *activityIndicatorView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
         UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicatorView.center = centerPoint;
        activityIndicatorView.tag = 1;
        [self addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];

        frame = CGRectMake(0.0f, 128.0f, 172.0f, 20.0f);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = NSLocalizedString(title, nil);
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowColor = [UIColor darkGrayColor];
        titleLabel.shadowOffset = CGSizeMake(0, 2);
        titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        titleLabel.tag = 2;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
        titleLabel.textAlignment = NSTextAlignmentCenter;
#else
        titleLabel.textAlignment = UITextAlignmentCenter;
#endif

        [self addSubview:titleLabel];
    }
    return self;
}

#pragma mark - Show & Hide

- (void)show {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    // Add it as a subview to the frontmost window.
    self.hidden = NO;
    UIView *superview = [[[UIApplication sharedApplication] windows] lastObject];
    [superview addSubview:self];
    self.center = [[UIApplication sharedApplication].keyWindow convertPoint:self.center toView:superview];
}

- (void)dismissAnimated:(BOOL)animated {
    [UIView animateWithDuration:(animated ? 0.3 : 0.0) animations:^{
        self.alpha = 0.0f; // fades
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1.0f; // restores to default
        [self removeFromSuperview];
        sharedOverlayView = nil;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

@end
