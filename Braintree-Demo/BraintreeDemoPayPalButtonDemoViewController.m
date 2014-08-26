#import "BraintreeDemoPayPalButtonDemoViewController.h"

#import <Braintree/Braintree.h>
#import <Braintree/BTClient+BTPayPal.h>
#import <Braintree/BTVenmoAppSwitchHandler.h>

@interface BraintreeDemoPayPalButtonDemoViewController () <BTAppSwitchingDelegate, BTPayPalButtonDelegate, BTPayPalAdapterDelegate>
@property (nonatomic, strong) Braintree *braintree;

@property (nonatomic, strong) BTPayPalButton *payPalButton;
@property (nonatomic, weak) IBOutlet UIButton *customPayPalButton;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) BTPayPalAdapter *customPayPalAdapter;

@property (nonatomic, copy) void (^completionBlock)(NSString *nonce);

@end

@implementation BraintreeDemoPayPalButtonDemoViewController

- (instancetype)initWithBraintree:(Braintree *)braintree completion:(void (^)(NSString *))completionBlock {
    self = [self init];
    if (self) {
        self.braintree = braintree;
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.payPalButton = [self.braintree payPalButtonWithDelegate:self];

    if (self.payPalButton) {
        self.payPalButton.delegate = self;
        [self.payPalButton setTranslatesAutoresizingMaskIntoConstraints:NO];

        // Add PayPal button as subview
        [self.view addSubview:self.payPalButton];

        // Setup Auto Layout constraints
        NSDictionary *views = @{ @"payPalButton": self.payPalButton };

        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[payPalButton]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.payPalButton
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0]];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.payPalButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.payPalButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:60]];
    }

    self.customPayPalAdapter = [[BTPayPalAdapter alloc] initWithClient:self.braintree.client];
    self.customPayPalAdapter.delegate = self;

    if (!self.customPayPalAdapter) {
        self.customPayPalButton.hidden = YES;
    }
    self.customPayPalButton.alpha = 0;

    self.emailLabel.text = nil;
}

- (IBAction)didTapVenmo:(__unused id)sender {
    [BTVenmoAppSwitchHandler sharedHandler].returnURLScheme = @"com.braintreepayments.Braintree-Demo.payments";
    [[BTVenmoAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.braintree.client delegate:self];
}

- (void)willReceivePaymentMethod {
    [self.activityIndicator startAnimating];
    self.emailLabel.text = nil;
}

- (void)fail:(NSError *)error {
    NSLog(@"%@", error);
    [self.activityIndicator stopAnimating];
    self.emailLabel.text = @"An error occurred";
    [[[UIAlertView alloc] initWithTitle:@"Failed to tokenize PayPal Auth Code"
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}


- (void)receivePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self.activityIndicator stopAnimating];
    if ([paymentMethod isKindOfClass:[BTPayPalPaymentMethod class]]) {
        self.emailLabel.text = [(BTPayPalPaymentMethod *)paymentMethod email];
    } else {
        self.emailLabel.text = @"Got a nonce!";
    }
    
    NSLog(@"Got a nonce! %@", paymentMethod.nonce);
    if (self.completionBlock) {
        self.completionBlock(paymentMethod.nonce);
    }
}

- (void)cancel {
    [self.activityIndicator stopAnimating];
    self.emailLabel.text = @"Canceled 🔰";
}

#pragma mark PayPal Button Delegate Methods

- (void)payPalButtonWillCreatePayPalPaymentMethod:(__unused BTPayPalButton *)button {
    [self willReceivePaymentMethod];
}

- (void)payPalButton:(__unused BTPayPalButton *)button didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod {
    [self receivePaymentMethod:paymentMethod];
}

- (void)payPalButton:(__unused BTPayPalButton *)button didFailWithError:(NSError *)error {
    [self fail:error];
}

- (void)payPalButtonDidCancel {
    [self cancel];
}

#pragma mark PayPal Adapter Delegate Methods

- (void)payPalAdapterWillCreatePayPalPaymentMethod:(__unused BTPayPalAdapter *)payPalAdapter {
    [self willReceivePaymentMethod];
}

- (void)payPalAdapter:(__unused BTPayPalAdapter *)payPalAdapter didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod {
    [self receivePaymentMethod:paymentMethod];
}

- (void)payPalAdapter:(__unused BTPayPalAdapter *)payPalAdapter didFailWithError:(NSError *)error {
    [self fail:error];
}

- (void)payPalAdapterDidCancel:(__unused BTPayPalAdapter *)payPalAdapter {
    [self cancel];
}

- (void)payPalAdapter:(__unused BTPayPalAdapter *)payPalAdapter requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController
                       animated:YES
                     completion:nil];
}

- (void)payPalAdapter:(__unused BTPayPalAdapter *)payPalAdapter requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES
                                       completion:nil];
}


#pragma mark Custom PayPal Button

- (IBAction)tappedCustomPayPalButton:(__unused id)sender {
    NSLog(@"Tapped PayPal - initiated PayPal auth using BTPayPalAdapter");
    [self.customPayPalAdapter initiatePayPalAuth];
}

- (IBAction)toggledIntegrationMethod:(UISegmentedControl *)sender {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.payPalButton.alpha = 1-sender.selectedSegmentIndex;
                         self.customPayPalButton.alpha = sender.selectedSegmentIndex;
                     }];
}

#pragma mark - 

- (void)appSwitcherWillSwitch:(id<BTAppSwitching>)switcher {
    NSLog(@"appSwitcherWillSwitch:%@", switcher);
}

- (void)appSwitcherWillCreatePaymentMethod:(id<BTAppSwitching>)switcher {
    NSLog(@"appSwitcherWillCreatePaymentMethod:%@", switcher);
    [self willReceivePaymentMethod];
}

- (void)appSwitcher:(id<BTAppSwitching>)switcher didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    NSLog(@"appSwitcher:%@ didCreatePaymentMethod: %@", switcher, paymentMethod);
    [self receivePaymentMethod:paymentMethod];
}

- (void)appSwitcher:(id<BTAppSwitching>)switcher didFailWithError:(NSError *)error {
    NSLog(@"appSwitcher:%@ error: %@", switcher, error);
    [self fail:error];
}

- (void)appSwitcherDidCancel:(id<BTAppSwitching>)switcher {
    NSLog(@"appSwitcherDidCancel:%@", switcher);
    [self cancel];
}


@end


