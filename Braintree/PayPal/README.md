# Braintree-PayPal

iOS UI classes for adding PayPal as a Braintree payment option.

## Overview

This project provides two primary classes:

1. `BTPayPalViewController` is a `UIViewController` that provides the PayPal authentication UX and – on successful auth – a resulting transactable payment method.
2. `BTPayPalButton` is a `UIControl` that you can use to offer PayPal as a payment option to your user. It can be used by adding it to your view hierarchy and setting delegate methods. **(Deprecated - please see `BTPaymentButton` in the [Payments subspec](../Payments))**

This library depends on `Braintree/API`, which provides `BTClient`, used as an initialization parameter for both of the above.

Out of the box, `BTPayPalButton` is automatically configured to present a `BTPayPalViewController`
when the user taps it. This means that you are not required to override the `BTPayPalButton`'s delegate.

**Please note**: If the default behavior is not compatible with your views, you can implement a
 custom `BTPayPalButtonViewControllerPresenterDelegate`.

## Installation

Use [CocoaPods](https://cocoapods.com) and add the following to your `Podfile`:

```ruby
pod 'Braintree/PayPal'
```

CocoaPods automatically vendors the PayPal Mobile SDK, `libPayPalMobile-BT.a`, which is included. Braintree-PayPal-iOS is not compatible with the PayPal Mobile SDK.

## Integration

A straightforward integration approach is to just add a `BTPayPalButton` instance in your view hierarchy, then implement its `BTPayPalButtonDelegate` to receive results. Rough example:

1. Create an instance of `BTPayPalButton` either in your xib or storyboard or initialized in code and added as a subview, e.g.

```obj-c
- (void)viewDidLoad {
    self.payPalButton = [[BTPayPalButton alloc] init];
    [self.view addSubview:self.payPalButton];
}
```

2. Set the `client` and `delegate` properties of your `BTPayPalButton` instance, e.g.

```obj-c
self.payPalButton.client = [[BTClient alloc] initWithClientToken:MY_CLIENT_TOKEN];
self.payPalButton.delegate = self;
```

3. Implement the required `BTPayPalButtonDelegate` protocol methods:

```obj-c
- (void)payPalButton:(BTPayPalButton *)button addedPaymentMethod:(NSString *)paymentMethod {
    NSLog(@"Payment method %@ obtained and is ready for use", paymentMethod);
    // Send paymentMethod to your server for use...
}

- (void)payPalButtonRemovedPaymentMethod:(BTPayPalButton *)button {
    NSLog(@"Payment method was removed");
}
```

4. Optional: `BTPayPalButton` handles presentation of a `BTPayPalViewController` out of the box, but you can change the presentation by implementing
an additional optional `BTPayPalButtonViewControllerPresenterDelegate` method and setting the `presentationDelegate` property:

```obj-c
- (void)payPalButton:(BTPayPalButton *)button requestsPresentationOfViewController:(UIViewController *)viewController {
    // Use your own presentation code here, e.g.
    [self.navigationController pushViewController:viewController];
}
```
