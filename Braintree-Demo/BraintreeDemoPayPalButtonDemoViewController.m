#import "BraintreeDemoPayPalButtonDemoViewController.h"

#import <Braintree/Braintree.h>

@interface BraintreeDemoPayPalButtonDemoViewController () <BTPayPalButtonDelegate>
@property (nonatomic, strong) Braintree *braintree;

@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation BraintreeDemoPayPalButtonDemoViewController

- (instancetype)initWithBraintree:(Braintree *)braintree {
    self = [self init];
    if (self) {
        self.braintree = braintree;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    BTPayPalButton *payPalButton = [self.braintree payPalButtonWithDelegate:self];

    if (payPalButton) {
        payPalButton.delegate = self;
        [payPalButton setTranslatesAutoresizingMaskIntoConstraints:NO];

        // Add PayPal button as subview
        [self.view addSubview:payPalButton];

        // Setup Auto Layout constraints
        NSDictionary *views = NSDictionaryOfVariableBindings(payPalButton);

        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[payPalButton]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:payPalButton
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0]];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:payPalButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:payPalButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:60]];
    }
}

#pragma mark PayPal Button Delegate Methods

- (void)payPalButtonWillCreatePayPalPaymentMethod:(__unused BTPayPalButton *)button {
    [self.activityIndicator startAnimating];
    self.emailLabel.text = nil;
}

- (void)payPalButton:(__unused BTPayPalButton *)button didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod {
    [self.activityIndicator stopAnimating];
    self.emailLabel.text = paymentMethod.email;
    NSLog(@"Got a nonce! %@", paymentMethod.nonce);
}

- (void)payPalButton:(__unused BTPayPalButton *)button didFailWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
    self.emailLabel.text = @"An error occurred";
    [[[UIAlertView alloc] initWithTitle:@"Failed to tokenize PayPal Auth Code"
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

@end
