# Braintree iOS SDK

Braintree-iOS is a CocoaPod that provides easy and flexible Braintree payments in your iOS app.

## Documentation

Start with [**'Hello, Client!'**](https://developers.braintreepayments.com/ios/start/hello-client) which introduces the Braintree iOS Client SDK and covers basic setup, initialization and usage.

[**Braintree iOS Client SDK Documentation**](https://developers.braintreepayments.com/ios/sdk/client) covers setup and integration options, including custom PayPal and credit card tokenization.

[**cocoadocs.org/docsets/Braintree**](http://cocoadocs.org/docsets/Braintree) hosts the complete, up-to-date API documentation generated straight from the header files.

## Installation

Braintree is available through [CocoaPods](http://cocoapods.org).

Our preview pods are available from a dedicated Braintree CocoaPods specification repository. To use it, run:

```
pod repo add braintree https://github.com/braintree/CocoaPods.git
```

To add the library to your project, simply add it to your project's `Podfile`:

```
pod 'Braintree' # You can also specify a particular version here
```

Then run `pod install`.

If you've never used CocoaPods before, [this website](http://guides.cocoapods.org/using/getting-started.html) does a great job explaining what it is and how it works. We believe that dependency management will make iOS developers more productive and are curious about your feedback. (It is possible to pull in our code manually, but that is not recommended at this time.)

## Demo

Need instant gratification? Try out the library in a demo app first by enter this command in your shell:

```
pod try Braintree
```

`Braintree.xcworkspace` includes a demo app called `Braintree Demo` that presents a number of integration options. In order to run this demo, you will need to run a server that integrates with a Braintree client library and responds to `/client_token` with a valid client token.

We include a sample merchant server in this repository. Please see [Sample Merchant Server/README](Sample Merchant Server/README.md] for further instructions on running a sample server.


## Example Usage

The easy way to accept card and PayPal payments in your app is to present the Drop-In view controller:

```
#import <Braintree/Braintree.h>
// YourViewController.m

- (void)tappedMyPayButton {
  Braintree *braintree = [Braintree braintreeWithClientToken:CLIENT_TOKEN_FROM_SERVER];
  BTDropInViewController *dropIn = [braintree dropInViewControllerWithDelegate:self];
  [self presentViewController:dropIn
                     animated:YES
                   completion:nil];
}
```

## Architecture

There are several components that comprise this SDK:

* `Braintree` is the top-level entry point to the SDK. You are here.
* [Braintree-Drop-In](https://github.com/braintree/braintree_ios_preview/tree/master/Braintree/Drop-In) composes API with Credit Card and PayPal UI to create a "three liner" payment form. (See also BTDropInViewControler.h)
* [Braintree-Payments-UI](https://github.com/braintree/braintree_ios_preview/tree/master/Braintree/UI) is a set of reusable UI componenets related to payments.
* [Braintree-PayPal](https://github.com/braintree/braintree_ios_preview/tree/master/Braintree/PayPal) provides a PayPal button and view controller. (See also BTPayPalButton.)
* [Braintree-API](https://github.com/braintree/braintree_ios_preview/tree/master/Braintree/api) provides the networking and communications layer. (See also BTClient.)

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
