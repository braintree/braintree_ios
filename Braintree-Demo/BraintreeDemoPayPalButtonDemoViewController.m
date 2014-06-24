#import "BraintreeDemoPayPalButtonDemoViewController.h"

#import <Braintree/Braintree.h>

@interface BraintreeDemoPayPalButtonDemoViewController ()
@property (nonatomic, strong) Braintree *braintree;
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
    // Construct PayPal Button
    UIView *payPalButton = [self.braintree payPalButtonWithCompletion:^(NSString *nonce, NSError *error) {
        if (error != nil) {
            [[[UIAlertView alloc] initWithTitle:@"Failed to tokenize Auth Code"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
    }];
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

@end
