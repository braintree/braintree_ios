#import "BTPayPalControl.h"

#import "BTUIPaymentMethodView.h"
#import "BTPayPalViewController.h"
#import "BTPayPalHorizontalSignatureWhiteView.h"
#import "BTUI.h"
#import "BTLogger.h"

@interface BTPayPalControl () <BTPayPalViewControllerDelegate, BTPayPalControlViewControllerPresenterDelegate>
@property (nonatomic, strong) BTPayPalHorizontalSignatureWhiteView *payPalHorizontalSignatureView;
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

- (void)setupViews {
    self.accessibilityLabel = NSLocalizedString(@"Pay with PayPal", @"BTPayPalControl accessibility label");
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];

    // Create PayPal Control Content View (Logged out PayPal button)
    self.layer.cornerRadius = 5.0f;
    self.layer.borderWidth = 0.5f;

    self.payPalHorizontalSignatureView = [[BTPayPalHorizontalSignatureWhiteView alloc] init];
    [self.payPalHorizontalSignatureView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.payPalHorizontalSignatureView.userInteractionEnabled = NO;

    [self addSubview:self.payPalHorizontalSignatureView];

    self.backgroundColor = [[BTUI braintreeTheme] payPalButtonBlue];
    self.layer.borderColor = [UIColor clearColor].CGColor;

    [self addConstraints:[self defaultConstraints]];

    // Listen for taps
    [self addTarget:self action:@selector(didReceiveTouch) forControlEvents:UIControlEventTouchUpInside];
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
        [self requestPresentationOfViewController:self.braintreePayPalViewController];
    }
}

- (id<BTPayPalControlViewControllerPresenterDelegate>)presentationDelegate {
    return _presentationDelegate ?: self;
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

- (void)informDelegateWillCreatePayPalPaymentMethod {
    if ([self.delegate respondsToSelector:@selector(payPalControlWillCreatePayPalPaymentMethod:)]) {
        [self.delegate payPalControlWillCreatePayPalPaymentMethod:self];
    }
}

#pragma mark Presentation Delegate Messages

- (void)requestDismissalOfViewController:(UIViewController *)viewController {
    if ([self.presentationDelegate respondsToSelector:@selector(payPalControl:requestsDismissalOfViewController:)]) {
        [self.presentationDelegate payPalControl:self requestsDismissalOfViewController:viewController];
    }
}

- (void)requestPresentationOfViewController:(UIViewController *)viewController {
    if ([self.presentationDelegate respondsToSelector:@selector(payPalControl:requestsPresentationOfViewController:)]) {
        [self.presentationDelegate payPalControl:self requestsPresentationOfViewController:viewController];
    }
}

#pragma mark - UIControl methods

- (void)setHighlighted:(BOOL)highlighted {
    [UIView animateWithDuration:0.08f animations:^{
        self.backgroundColor = highlighted ? [[BTUI braintreeTheme]  payPalButtonActiveBlue] : [[BTUI braintreeTheme]  payPalButtonBlue];
    }];
}


#pragma mark - BTPayPalViewControllerDelegate implementation

- (void)payPalViewControllerWillCreatePayPalPaymentMethod:(BTPayPalViewController *)viewController {
    [self requestDismissalOfViewController:viewController];
    [self informDelegateWillCreatePayPalPaymentMethod];
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
    [self requestDismissalOfViewController:viewController];
    [self informDelegateDidFailWithError:error];
}

- (void)payPalViewControllerDidCancel:(BTPayPalViewController *)viewController {
    self.userInteractionEnabled = YES;
    self.braintreePayPalViewController = nil;
    [self requestDismissalOfViewController:viewController];
}

#pragma mark - BTPayPalControlViewControllerPresenterDelegate default implementation

- (void)payPalControl:(__unused BTPayPalControl *)control requestsPresentationOfViewController:(UIViewController *)viewController {
    [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)payPalControl:(__unused BTPayPalControl *)control requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Auto Layout Constraints

- (NSArray *)defaultConstraints {
    CGFloat BTPayPalControlHorizontalSignatureWidth = 95.0f;
    CGFloat BTPayPalControlHorizontalSignatureHeight = 23.0f;
    CGFloat BTPayPalControlMinHeight = 40.0f;
    CGFloat BTPayPalControlMaxHeight = 60.0f;
    CGFloat BTPayPalControlMinWidth = 240.0f;

    NSDictionary *metrics = @{ @"minHeight": @(BTPayPalControlMinHeight),
                               @"maxHeight": @(BTPayPalControlMaxHeight),
                               @"required": @(UILayoutPriorityRequired),
                               @"minWidth": @(BTPayPalControlMinWidth) };
    NSDictionary *views = @{ @"self": self,
                             @"payPalHorizontalSignatureView": self.payPalHorizontalSignatureView };


    NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:6];
    // Signature centerY
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1.0f
                                   constant:0.0f]];

    // Signature centerX
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0f
                                   constant:0.0f]];

    // Signature width
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:BTPayPalControlHorizontalSignatureWidth]];

    // Signature height
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:BTPayPalControlHorizontalSignatureHeight]];

    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(>=minHeight@required,<=maxHeight@required)]"
                                             options:0
                                             metrics:metrics
                                               views:views]];

    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:[self(>=260@required)]"
                                             options:0
                                             metrics:metrics
                                               views:views]];
    return constraints;
}

@end
