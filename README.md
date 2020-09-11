# Braintree iOS SDK

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<!--[![Travis CI build status](https://travis-ci.org/braintree/braintree_ios.svg?branch=master)](https://travis-ci.org/braintree/braintree_ios) -->

Welcome to Braintree's iOS SDK. This library will help you accept card and alternative payments in your iOS app.

**The Braintree iOS SDK requires Xcode 10+**. It permits a Deployment Target of iOS 8.0 or higher.

## Supported Payment Methods

- [Credit Cards](https://developers.braintreepayments.com/guides/credit-cards/overview)
- [PayPal](https://developers.braintreepayments.com/guides/paypal/overview)
- [Pay with Venmo](https://developers.braintreepayments.com/guides/venmo/overview)
- [Apple Pay](https://developers.braintreepayments.com/guides/apple-pay/overview)
- [ThreeDSecure](https://developers.braintreepayments.com/guides/3d-secure/overview)
- [Visa Checkout](https://developers.braintreepayments.com/guides/visa-checkout/overview)

## Installation

We recommend using either [CocoaPods](https://github.com/CocoaPods/CocoaPods) or [Carthage](https://github.com/Carthage/Carthage) to integrate the Braintree SDK with your project.

#### CocoaPods
```
# Includes Cards and PayPal
pod 'Braintree'

# Optionally include additional Pods
pod 'Braintree/DataCollector'
pod 'Braintree/Venmo'
```

*Note:* If you are using version 4.x.x of the Braintree iOS SDK in Xcode 12, you may see the warning `The iOS Simulator deployment target is set to 8.0, but the range of supported deployment target versions is 9.0 to 14.0.99`. This will not prevent your app from compiling. This is a [CocoaPods issue](https://github.com/CocoaPods/CocoaPods/issues/7314) with a known workaround.

#### Carthage
Add `github "braintree/braintree_ios"` to your `Cartfile`, and [add the frameworks to your project](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

## Documentation

Start with [**'Hello, Client!'**](https://developers.braintreepayments.com/ios/start/hello-client) for instructions on basic setup and usage.

Next, read the [**full documentation**](https://developers.braintreepayments.com/ios/sdk/client) for information about integration options, such as Drop-In UI, PayPal, and credit card tokenization.

## Demo

A demo app is included in the project. To run it, run `pod install` and then open `Braintree.xcworkspace` in Xcode.

## Feedback

The Braintree iOS SDK is in active development, we welcome your feedback!

Here are a few ways to get in touch:

* [GitHub Issues](https://github.com/braintree/braintree_ios/issues) - For generally applicable issues and feedback
* [Braintree Support](https://articles.braintreepayments.com/) / support@braintreepayments.com - for personal support at any phase of integration

## Help

* Read the headers
* [Read the Braintree docs](https://developers.braintreepayments.com/ios/sdk/client)
* [Check out the reference docs](https://braintree.github.io/braintree_ios/)
* Find a bug? [Open an issue](https://github.com/braintree/braintree_ios/issues)
* Want to contribute? [Check out contributing guidelines](CONTRIBUTING.md) and [submit a pull request](https://help.github.com/articles/creating-a-pull-request).

### License

The Braintree iOS SDK is open source and available under the MIT license. See the [LICENSE](LICENSE) file for more info.
