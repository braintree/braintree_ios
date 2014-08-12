# Create a Custom PayPal Control

The UI elements we provide (`BTPayPalButton` and `BTDropInViewController`) enable PayPal Touch automatically. If you'd like to use your own UI, use `BTPayPalAdapter`, which provides a common interface for all available PayPal auth mechanisms.

Create a `BTPayPalAdapter`, set its delegate, and initiate it on user interaction:

```obj-c
@interface MyViewController : UIViewController <BTPayPalAdapterDelegate>
@property (nonatomic, strong) BTPayPalAdapter *adapter;
@end

@implementation MyViewController

- (void)viewDidLoad {
  // Create a BTPayPalAdapter using a `BTClient` and set its delegate
  self.adapter = [[BTPayPalAdapter alloc] initWithClient:client];
  self.adapter.delegate = self;

  // Setup a custom PayPal Button with our own target-action handler.
  UIButton *myPayPalButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [myPayPalButton setTitle:@"Pay with PayPal" forState:UIControlStateNormal];
  [myPayPalButton setFrame:self.view.frame];
  {myPalPalButton addTarget:self action:@selector(payPalButtonDidReceiveTouch:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:myPalPalButton];
}

// When a user taps our custom PayPal button, invoke `initiatePayPalAuth`
// on the `payPalAdapter`.
- (IBAction)payPalButtonDidReceiveTouch:(UIButton *)sender {
  [self.adapter initiatePayPalAuth];
}

// ...
```

Once initiated, as the PayPal auth flow progresses, you will be notified and requested to perform actions, such as presenting a view controller. Here is a stub implementation of `BTPayPalAdapterDelegate`:

```obj-c
- (void)payPalAdapterWillCreatePayPalPaymentMethod:(BTPayPalAdapter *)payPalAdapter {
    // Called after successful authorization, but before the payment method is created.
    // TODO - indicate activity to user
    self.myPayPalButton.userInteractionEnabled = NO;
}

- (void)payPalAdapter:(BTPayPalAdapter *)payPalAdapter didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod {
    self.myPayPalButton.userInteractionEnabled = YES;
    // TODO - Send payment method nonce to your server for use
}

- (void)payPalAdapter:(BTPayPalAdapter *)payPalAdapter didFailWithError:(NSError *)error {
    self.myPayPalButton.userInteractionEnabled = YES;
    // TODO - Handle error (display to user, report to server, etc)
}

- (void)payPalAdapterDidCancel:(BTPayPalAdapter *)payPalAdapter {
    self.myPayPalButton.userInteractionEnabled = YES;
    // TODO - Any other cancellation handling
}

// In case app switch is unavailable or disabled, we may be responsible for presenting Braintree's PayPal auth UI to the user
- (void)payPalAdapter:(BTPayPalAdapter *)payPalAdapter requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// In case app switch is unavailable or disabled, we may be responsible for dismissing Braintree's PayPal auth UI
- (void)payPalAdapter:(BTPayPalAdapter *)payPalAdapter requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
```
