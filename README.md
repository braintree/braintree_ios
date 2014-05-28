# Braintree iOS SDK

Braintree-iOS is a CocoaPod that provides easy and flexible Braintree payments in your iOS app.

### Release Candidate!

This is the v3 **Release Candidate** of the Braintree iOS SDK. Documentation and code are not final, and some bugs and issues remain. Public headers may change before 3.0.

Please watch the [CHANGELOG.md](CHANGELOG.md) for changes, stay up to date with the latest pre-release, and don't hestitate to [contact us](#feedback) with any questions or feedback.

## Installation

Braintree is available through [CocoaPods](http://cocoapods.org).

Our preview pods are available form a dedicated Braintree CocoaPods specification repository. To use it, run:

```
pod repo add https://github.com/braintree/CocoaPods.git
```

To add the library to your project, simply add it to your project's `Podfile`:

```
pod 'Braintree' # You can also specify a particular version here
```

Then run `pod install`.

Need instant gratification? Try out the library in a demo app first:

```
pod try braintree-ios
```

If you've never used CocoaPods before, [this website](http://guides.cocoapods.org/using/getting-started.html) does a great job explaining what it is and how it works. We believe that dependency management will make iOS developers more productive and are curious about your feedback. (It is possible to pull in our code manually, but that is not recommended at this time.)

## Usage

### Obtain a Client Token

Regardless of the integration method, you'll need to obtain a client token from your Braintree server-side integration. It might look something like this:

```
AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
[manager GET:@"https://your-server/client_token.json"
  parameters:@{ @"your-server-authentication": @"token", @"your-customer-session": @"session"}
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
       // Setup braintree with responseObject[@"client_token"]
     }
     failure:nil];
```

You should obtain a new client token often, at least as often as your app restarts. For the best experience, you should kick off this network operation before it would block a user interaction.

### Drop-In

This is the easy way to accept card and PayPal payments in your app.

Simply present the Drop-In view controller:

```
#import <Braintree/Braintree.h>
// YourViewController.m

- (void)tappedMyPayButton {
  // Note: a client token is required for authentication
  Braintree *braintree = [Braintree braintreeWithClientToken:CLIENT_TOKEN_FROM_SERVER];
  BTDropInViewController *dropIn = [braintree dropInViewControllerWithCompletion:^(NSString *nonce, NSError *error){
    // TODO: Communicate the payment method nonce to your server.
  }];
  // TODO: Customize your Drop In View Controller. See BTDropInViewController.h.
  [self presentViewController:dropIn
                     animated:YES
                   completion:nil];
}
```

Take a look at `BTDropInViewController.h` for more information about customizing the Drop In. If you use Storyboard, it may be easier to use `BTDropInViewController` directly.

### Custom

You may need more flexibility than the Drop In offers. For instance, you may want to use your own card entry UI, or you only want to add a PayPal button to your existing payment options.

#### Save a Card

To use Braintree card payment processing with your own UI, simply call `tokenizeCardWithNumber:expirationMonth:expirationYear:completion:` with the user's card details.

```
// YourPaymentsHelper.m
#import <Braintree/Braintree.h>

- (void)tokenizeCard {
  Braintree *braintree = [Braintree braintreeWithClientToken:CLIENT_TOKEN_FROM_SERVER];
  [braintree tokenizeCardWithNumber:@"4111111111111111"
                    expirationMonth:@"12"
                     expirationYear:@"2018"
                         completion:^(NSString *nonce, NSError *error){
                            // TODO: Communicate the nonce to your server
                         }];
}
```

In the completion block, send the resulting `nonce` to your server for use.


#### Accept PayPal

To add a PayPal button to your payment options, create a `BTPayPalControl` and add it to your view.

```
// YourViewController.m
#import <Braintree/Braintree.h>

- (void)viewDidLoad {
  Braintree *braintree = [Braintree braintreeWithClientToken:CLIENT_TOKEN_FROM_SERVER];
  BTPayPalControl *payPalControl = [braintree payPalControlWithCompletion:^(NSString *nonce, NSError *error){
    // Communicate the nonce to your server
  }];
  [payPalControl setFrame:CGRectMake(0,0,60,120)];
  [self.view addSubview:payPalControl];
}
```

When tapped, this `UIControl` will start the PayPal login flow within your application and asynchronously create a payment nonce. Implement the completion block to send the resulting `nonce` value to your server for use.

You may use `BTPayPalControl` (or even a `BTPayPalViewController`) directly if you prefer, but this implementation is more complex. This may be especially useful for developers who use XIBs and Storyboards. The header files contain in-depth documentation.


## Architecture

There are several components that comprise this SDK:

* `Braintree` is the top-level entry point to the SDK. You are here.
* [Braintree-Drop-In](https://github.com/braintree/braintree_ios_preview/tree/master/Braintree/Drop-In) composes API with Credit Card and PayPal UI to create a "three liner" payment form. (See also BTDropInViewControler.h)
* [Braintree-Payments-UI](https://github.com/braintree/braintree_ios_preview/tree/master/Braintree/UI) is a set of reusable UI componenets related to payments.
* [Braintree-PayPal](https://github.com/braintree/braintree_ios_preview/tree/master/Braintree/PayPal) provides a PayPal button and view controller. (See also BTPayPalControl.)
* [Braintree-API](https://github.com/braintree/braintree_ios_preview/tree/master/Braintree/api) provides the networking and communications layer; it depends on AFNetworking. (See also BTClient.)

The individual components may be of interest for advanced integrations and are each available as subspecs.

## Project Requirements

* Xcode 5 and iOS SDK 7
* iOS 7.0+ target deployment
* All devices (iPhone and iPad of all sizes and resolutions) and the simulator
* CocoaPods integration


## Get Help

* [Read the headers](https://github.com/braintree/braintree_ios_preview/blob/master/Braintree/Braintree.h)
* [Read the docs](https://github.com/braintree/client-sdk-docs)
* Find a bug? [Open an issue](https://github.com/braintree/braintree_ios_preview/issues/new)
* Want to contribute? [Check out contributing guidelines](CONTRIBUTING.md) and [submit a pull request](https://github.com/braintree/braintree_ios_preview/compare/).


## Meta

### Feedback

Braintree-iOS 3.0.0 is brand new and most certainly a work in progress. We appreciate the time you take to try it out and welcome your feedback!

Here are a few ways to get in touch:

* Github Issues - For issues and feedback specific to Braintree iOS
* [Gitter.im chat room](https://gitter.im/braintree/braintree_ios_preview) - We'll be hanging out here for quick questions
* support@braintreepayments.com - for General Braintree support issues
* 877.511.5036 - for General Braintree support issues (Real people answer our phones)

Thanks!

The iOS SDK Team,
[Mickey Reiss](@mickeyreiss) - [Brent Fitzgerald](@burnto) - [Udit Manektala](@udit99) - [The Braintree Team](https://braintreepayments.com/team)

### License

The Braintree SDK for iOS is open source and available under the MIT license. See the [LICENSE](LICENSE) file for more info.
