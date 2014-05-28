#import "BTPayPalControl.h"

#import "BTUIPaymentMethodView.h"
#import "BTPayPalViewController.h"

#import "BTPayPalControlContentView.h"

#import "BTLogger.h"

@interface BTPayPalControl () <BTPayPalViewControllerDelegate, BTPayPalControlViewControllerPresenterDelegate>

@property (nonatomic, strong) BTPayPalControlContentView *contentView;

@property (nonatomic, strong) BTPayPalViewController *braintreePayPalViewController;
@end

@implementation BTPayPalControl

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self setupViews];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)setupViews {
    self.accessibilityLabel = NSLocalizedString(@"Pay with PayPal", @"BTPayPalControl accessibility label");
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];

    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];

    // Create PayPal Control Content View (Logged out PayPal button)
    self.contentView = [[BTPayPalControlContentView alloc] initWithFrame:self.bounds];
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];

    // Add subviews
    [self addSubview:self.contentView];

    // Listen for taps
    [self addTarget:self action:@selector(didReceiveTouch) forControlEvents:UIControlEventTouchUpInside];

    // Constrain content to be flush
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:@{@"contentView": self.contentView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:@{@"contentView": self.contentView}]];
}

- (void)updateViewsForLoggedOutState {
    self.userInteractionEnabled = YES;
    self.contentView.alpha = 1.0f;
}

- (void)didReceiveTouch {
    if (self.client == nil) {
        [[BTLogger sharedLogger] log:@"BTPayPalControl tapped without a client. You must assign a BTClient to the the BTPayPalControl before it requests presents presentation of the PayPal view controller."];
        return;
    }

    // Only allow presentation of one braintreePayPalViewController at a time.
    if (self.braintreePayPalViewController == nil) {
        self.userInteractionEnabled = NO;
        self.braintreePayPalViewController = [[BTPayPalViewController alloc] initWithClient:self.client];
        self.braintreePayPalViewController.delegate = self;
        if ([self.presentationDelegate respondsToSelector:@selector(payPalControl:requestsPresentationOfViewController:)]) {
            [self.presentationDelegate payPalControl:self requestsPresentationOfViewController:self.braintreePayPalViewController];
        }
    }
}

- (id<BTPayPalControlViewControllerPresenterDelegate>)presentationDelegate {
    return _presentationDelegate ?: self;
}

- (void)clear {
    [self updateViewsForLoggedOutState];
}

#pragma mark State Change Messages

- (void)informDelegateDidCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)payPalPaymentMethod {
    if ([self.delegate respondsToSelector:@selector(payPalControl:didCreatePayPalPaymentMethod:)]) {
        [self.delegate payPalControl:self didCreatePayPalPaymentMethod:payPalPaymentMethod];
    }

    if (self.completionBlock) {
        self.completionBlock(payPalPaymentMethod, nil);
    }
}
- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(payPalControl:didFailWithError:)]) {
        [self.delegate payPalControl:self didFailWithError:error];
    }

    if (self.completionBlock) {
        self.completionBlock(nil, error);
    }
}

#pragma mark - UIControl methods

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self.contentView setHighlighted:highlighted];
}


#pragma mark - BTPayPalViewControllerDelegate implementation

- (void)payPalViewControllerWillCreatePayPalPaymentMethod:(BTPayPalViewController *)viewController {
    if ([self.presentationDelegate respondsToSelector:@selector(payPalControl:requestsDismissalOfViewController:)]) {
        [self.presentationDelegate payPalControl:self requestsDismissalOfViewController:viewController];
    }
    if ([self.delegate respondsToSelector:@selector(payPalControlWillCreatePayPalPaymentMethod:)]) {
        [self.delegate payPalControlWillCreatePayPalPaymentMethod:self];
    }
}

- (void)payPalViewController:(__unused BTPayPalViewController *)viewController didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)payPalPaymentMethod {
    self.userInteractionEnabled = YES;
    self.braintreePayPalViewController = nil;
    [self informDelegateDidCreatePayPalPaymentMethod:payPalPaymentMethod];
}

- (void)payPalViewController:(BTPayPalViewController *)viewController didFailWithError:(NSError *)error {
    self.userInteractionEnabled = YES;
    NSLog(@"PayPal view controller failed with error: %@", error);
    self.braintreePayPalViewController = nil;
    if ([self.presentationDelegate respondsToSelector:@selector(payPalControl:requestsDismissalOfViewController:)]) {
        [self.presentationDelegate payPalControl:self requestsDismissalOfViewController:viewController];
    }

    [self informDelegateDidFailWithError:error];
}

- (void)payPalViewControllerDidCancel:(BTPayPalViewController *)viewController {
    self.userInteractionEnabled = YES;
    self.braintreePayPalViewController = nil;
    if ([self.presentationDelegate respondsToSelector:@selector(payPalControl:requestsDismissalOfViewController:)]) {
        [self.presentationDelegate payPalControl:self requestsDismissalOfViewController:viewController];
    }
}

#pragma mark BTPayPalControlViewControllerPresenterDelegate default implementation

- (void)payPalControl:(__unused BTPayPalControl *)control requestsPresentationOfViewController:(UIViewController *)viewController {
    [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)payPalControl:(__unused BTPayPalControl *)control requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
