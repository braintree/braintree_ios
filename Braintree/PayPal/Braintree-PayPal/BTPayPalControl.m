#import "BTPayPalControl.h"

#import "BTUIPaymentMethodView.h"
#import "BTPayPalViewController.h"

#import "BTPayPalControlContentView.h"

#import <Braintree/BTLogger.h>

@interface BTPayPalControl () <BTPayPalViewControllerDelegate, BTPayPalControlViewControllerPresenterDelegate>

@property (nonatomic, copy) void (^paymentMethodCompletionBlock)(BTPaymentMethod *paymentMethod, NSError *error);

@property (nonatomic, strong) BTUIPaymentMethodView *loggedInView;
@property (nonatomic, strong) BTPayPalControlContentView *loggedOutView;

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
    self.loggedOutView = [[BTPayPalControlContentView alloc] initWithFrame:self.bounds];
    [self.loggedOutView setTranslatesAutoresizingMaskIntoConstraints:NO];

    // Create BTPaymentMethodView (Logged In view)
    self.loggedInView = [[BTUIPaymentMethodView alloc] init];
    self.loggedInView.type = BTUIPaymentMethodTypePayPal;
    [self.loggedInView setTranslatesAutoresizingMaskIntoConstraints:NO];

    // Add subviews
    [self addSubview:self.loggedOutView];
    [self addSubview:self.loggedInView];

    // Listen for taps
    [self addTarget:self action:@selector(didReceiveTouch) forControlEvents:UIControlEventTouchUpInside];


    //The Control is Logged out on setup
    [self updateViewsForLoggedOutState];

    // Constrain content to be flush
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[paymentMethodView]|" options:0 metrics:nil views:@{@"paymentMethodView": self.loggedInView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[paymentMethodView]|" options:0 metrics:nil views:@{@"paymentMethodView": self.loggedInView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[loggedOutView]|" options:0 metrics:nil views:@{@"loggedOutView": self.loggedOutView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[loggedOutView]|" options:0 metrics:nil views:@{@"loggedOutView": self.loggedOutView}]];
}

- (void)updateViewsForLoggedInState {
    self.loggedInView.processing = NO;
    self.userInteractionEnabled = NO;
    self.loggedInView.alpha = 1.0f;
    self.loggedOutView.alpha = 0.0f;
}

- (void)updateViewsForLoggedOutState {
    self.userInteractionEnabled = YES;
    self.loggedInView.alpha = 0.0f;
    self.loggedOutView.alpha = 1.0f;
}

- (void)updateViewsForProcessingState {
    [self updateViewsForLoggedInState];
    self.loggedInView.processing = YES;
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

- (void)informDelegateDidCreatePayPalAccount:(BTPayPalAccount *)payPalAccount {
    if ([self.delegate respondsToSelector:@selector(payPalControl:didCreatePayPalAccount:)]) {
        [self.delegate payPalControl:self didCreatePayPalAccount:payPalAccount];
    }

    if (self.paymentMethodCompletionBlock) {
        self.paymentMethodCompletionBlock(payPalAccount, nil);
    }
}
- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(payPalControl:didFailWithError:)]) {
        [self.delegate payPalControl:self didFailWithError:error];
    }

    if (self.paymentMethodCompletionBlock) {
        self.paymentMethodCompletionBlock(nil, error);
    }
}

#pragma mark - UIControl methods

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self.loggedOutView setHighlighted:highlighted];
}


#pragma mark - BTPayPalViewControllerDelegate implementation

- (void)payPalViewControllerWillCreatePayPalAccount:(BTPayPalViewController *)viewController {
    [self updateViewsForProcessingState];
    if ([self.presentationDelegate respondsToSelector:@selector(payPalControl:requestsDismissalOfViewController:)]) {
        [self.presentationDelegate payPalControl:self requestsDismissalOfViewController:viewController];
    }
}

- (void)payPalViewController:(__unused BTPayPalViewController *)viewController didCreatePayPalAccount:(BTPayPalAccount *)payPalAccount {
    [self.loggedInView setDetailDescription:payPalAccount.email];
    [self updateViewsForLoggedInState];
    self.braintreePayPalViewController = nil;

    [self informDelegateDidCreatePayPalAccount:payPalAccount];

}

- (void)payPalViewController:(BTPayPalViewController *)viewController didFailWithError:(NSError *)error {
    NSLog(@"PayPal view controller failed with error: %@", error);
    self.braintreePayPalViewController = nil;
    if ([self.presentationDelegate respondsToSelector:@selector(payPalControl:requestsDismissalOfViewController:)]) {
        [self.presentationDelegate payPalControl:self requestsDismissalOfViewController:viewController];
    }

    [self informDelegateDidFailWithError:error];
}

- (void)payPalViewControllerDidCancel:(BTPayPalViewController *)viewController {
    [self updateViewsForLoggedOutState];
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
