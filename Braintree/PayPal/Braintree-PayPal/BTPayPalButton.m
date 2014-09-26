#import "BTPayPalButton.h"

#import "BTUIPaymentMethodView.h"
#import "BTPayPalViewController.h"
#import "BTPayPalHorizontalSignatureWhiteView.h"
#import "BTUI.h"
#import "BTLogger_Internal.h"

@interface BTPayPalButton () <BTPayPalViewControllerDelegate, BTPayPalButtonViewControllerPresenterDelegate>
@property (nonatomic, strong) BTPayPalHorizontalSignatureWhiteView *payPalHorizontalSignatureView;
@property (nonatomic, strong) BTPayPalViewController *braintreePayPalViewController;
@end

@implementation BTPayPalButton

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
    self.accessibilityLabel = @"PayPal";
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];

    self.layer.borderWidth = 0.5f;

    self.payPalHorizontalSignatureView = [[BTPayPalHorizontalSignatureWhiteView alloc] init];
    [self.payPalHorizontalSignatureView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.payPalHorizontalSignatureView.userInteractionEnabled = NO;

    [self addSubview:self.payPalHorizontalSignatureView];

    self.backgroundColor = [[BTUI braintreeTheme] payPalButtonBlue];
    self.layer.borderColor = [UIColor clearColor].CGColor;

    [self addConstraints:[self defaultConstraints]];

    [self addTarget:self action:@selector(didReceiveTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveTouch {
    if (self.client == nil) {
        [[BTLogger sharedLogger] warning:@"BTPayPalButton tapped without a client. You must assign a BTClient to the the BTPayPalButton before it requests presents presentation of the PayPal view controller."];
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

- (id<BTPayPalButtonViewControllerPresenterDelegate>)presentationDelegate {
    return _presentationDelegate ?: self;
}

#pragma mark State Change Messages

- (void)informDelegateDidCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)payPalPaymentMethod {
    if ([self.delegate respondsToSelector:@selector(payPalButton:didCreatePayPalPaymentMethod:)]) {
        [self.delegate payPalButton:self didCreatePayPalPaymentMethod:payPalPaymentMethod];
    }
}
- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(payPalButton:didFailWithError:)]) {
        [self.delegate payPalButton:self didFailWithError:error];
    }
}

- (void)informDelegateWillCreatePayPalPaymentMethod {
    if ([self.delegate respondsToSelector:@selector(payPalButtonWillCreatePayPalPaymentMethod:)]) {
        [self.delegate payPalButtonWillCreatePayPalPaymentMethod:self];
    }
}

#pragma mark Presentation Delegate Messages

- (void)requestDismissalOfViewController:(UIViewController *)viewController {
    if ([self.presentationDelegate respondsToSelector:@selector(payPalButton:requestsDismissalOfViewController:)]) {
        [self.presentationDelegate payPalButton:self requestsDismissalOfViewController:viewController];
    }
}

- (void)requestPresentationOfViewController:(UIViewController *)viewController {
    if ([self.presentationDelegate respondsToSelector:@selector(payPalButton:requestsPresentationOfViewController:)]) {
        [self.presentationDelegate payPalButton:self requestsPresentationOfViewController:viewController];
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

#pragma mark - BTPayPalButtonViewControllerPresenterDelegate default implementation

- (void)payPalButton:(__unused BTPayPalButton *)button requestsPresentationOfViewController:(UIViewController *)viewController {
    [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)payPalButton:(__unused BTPayPalButton *)button requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Auto Layout Constraints

- (NSArray *)defaultConstraints {
    CGFloat BTPayPalButtonHorizontalSignatureWidth = 95.0f;
    CGFloat BTPayPalButtonHorizontalSignatureHeight = 23.0f;
    CGFloat BTPayPalButtonMinHeight = 40.0f;
    CGFloat BTPayPalButtonMaxHeight = 60.0f;
    CGFloat BTPayPalButtonMinWidth = 240.0f;

    NSDictionary *metrics = @{ @"minHeight": @(BTPayPalButtonMinHeight),
                               @"maxHeight": @(BTPayPalButtonMaxHeight),
                               @"required": @(UILayoutPriorityRequired),
                               @"minWidth": @(BTPayPalButtonMinWidth) };
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
                                   constant:BTPayPalButtonHorizontalSignatureWidth]];

    // Signature height
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:self.payPalHorizontalSignatureView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:BTPayPalButtonHorizontalSignatureHeight]];

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

- (CGSize)intrinsicContentSize {
    return CGSizeMake(320, UIViewNoIntrinsicMetric);
}

@end
