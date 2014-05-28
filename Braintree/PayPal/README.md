# Braintree-PayPal

iOS UI classes for adding PayPal as a Braintree payment option.

## Overview

This project provides two primary classes:

1. `BTPayPalControl` is a `UIControl` that you can use to offer PayPal as a payment option to your user. It can be used by adding it to your view hierarchy and setting delegate methods.
2. `BTPayPalViewController` is a `UIViewController` that provides the PayPal authentication UX and – on successful auth – a resulting transactable payment method.

This library depends on `Braintree/API`, which provides `BTClient`, used as an initialization parameter for both of the above.

Out of the box, `BTPayPalControl` is automatically configured to present a `BTPayPalViewController`
when the user taps it. This means that you are not required to override the `BTPayPalControl`'s delegate.

**Please note**: If the default behavior is not compatible with your views, you can implement a
 custom `BTPayPalControlViewControllerPresenterDelegate`.

## Installation

Use [CocoaPods](https://cocoapods.com) and add the following to your `Podfile`:

```
pod 'Braintree/PayPal'
```

CocoaPods automatically vendors the PayPal Mobile SDK, `libPayPalMobile.a`, which is included. Braintree-PayPal-iOS is not compatible with the PayPal Mobile SDK.

## Integration

A straightforward integration approach is to just add a `BTPayPalControl` instance in your view hierarchy, then implement its `BTPayPalControlDelegate` to receive results. Rough example:

1. Create an instance of `BTPayPalControl` either in your xib or storyboard or initialized in code and added as a subview, e.g.

```
- (void)viewDidLoad {
  self.payPalControl = [[BTPayPalControl alloc] init];
  [self.view addSubview:self.payPalControl];
}
```

2. Set the `client` and `delegate` properties of your `BTPayPalControl` instance, e.g.

```
self.payPalControl.client = [[BTClient alloc] initWithClientToken:MY_CLIENT_TOKEN];
self.payPalControl.delegate = self;
```

3. Implement the required `BTPayPalControlDelegate` protocol methods:

```
- (void)payPalControl:(BTPayPalControl *)control addedPaymentMethod:(NSString *)paymentMethod {
  NSLog(@"Payment method %@ obtained and is ready for use", paymentMethod);
  // Send paymentMethod to your server for use...
}

- (void)payPalControlRemovedPaymentMethod:(BTPayPalControl *)control {
  NSLog(@"Payment method was removed");
}
```

4. Optional: `BTPayPalControl` handles presentation of a `BTPayPalViewController` out of the box, but you can change the presentation by implementing
an additional optional `BTPayPalControlViewControllerPresenterDelegate` method and setting the `presentationDelegate` property:

```
- (void)payPalControl:(BTPayPalControl *)control requestsPresentationOfViewController:(UIViewController *)viewController {
  // Use your own presentation code here, e.g.
  [self.navigationController pushViewController:viewController];
}
```
