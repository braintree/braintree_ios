# Braintree iOS SDK

[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Braintree.svg?style=flat)](https://cocoapods.org/pods/Braintree)
[![Swift Package Manager compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

![GitHub Actions Tests](https://github.com/braintree/braintree_ios/workflows/Tests/badge.svg)

Welcome to Braintree's iOS SDK. This library will help you accept card and alternative payments in your iOS app.

v5 is the latest major version of Braintree iOS. To update from v4, see the [v5 migration guide](https://github.com/braintree/braintree_ios/blob/master/V5_MIGRATION.md).

**The Braintree iOS SDK permits a deployment target of iOS 12.0 or higher**. It requires Xcode 12+ and Swift 5.1+.

## Supported Payment Methods

- [Credit Cards](https://developer.paypal.com/braintree/docs/guides/credit-cards/overview)
- [PayPal](https://developer.paypal.com/braintree/docs/guides/paypal/overview)
- [Pay with Venmo](https://developer.paypal.com/braintree/docs/guides/venmo/overview)
- [Apple Pay](https://developer.paypal.com/braintree/docs/guides/apple-pay/overview)
- [ThreeDSecure](https://developer.paypal.com/braintree/docs/guides/3d-secure/overview)
- [Visa Checkout](https://developer.paypal.com/braintree/docs/guides/secure-remote-commerce/overview)

## Installation

We recommend using [Swift Package Manager](https://swift.org/package-manager/), [CocoaPods](https://github.com/CocoaPods/CocoaPods), or [Carthage](https://github.com/Carthage/Carthage) to integrate the Braintree SDK with your project.

### Swift Package Manager
_This feature is only available in v5._

To add the `Braintree` package to your Xcode project, select _File > Swift Packages > Add Package Dependency_ and enter `https://github.com/braintree/braintree_ios` as the repository URL. Tick the checkboxes for the specific Braintree libraries you wish to include.

If you look at your app target, you will see that the Braintree libraries you chose are automatically linked as a frameworks to your app (see _General > Frameworks, Libraries, and Embedded Content_).

*`BraintreePayPal` and `BraintreePaymentFlow` also require the inclusion of the `PayPalDataCollector` module.*

In your app's source code files, use the following import syntax to include Braintree's libraries:
```
import BraintreeCore
import BraintreeCard
import BraintreeApplePay
import BraintreePayPal
```

**Braintree 5.4.2+ requires Xcode 12.5+ for SPM.** We recommend using the latest version for the simplest SPM integration. If using Braintree 5.4.1 and below, please see our [Swift Package Manager guide](https://github.com/braintree/braintree_ios/blob/master/SWIFT_PACKAGE_MANAGER.md) for specific workarounds required to use these older versions.


### CocoaPods
```
# Includes Cards and PayPal
pod 'Braintree'

# Optionally include additional Pods
pod 'Braintree/DataCollector'
pod 'Braintree/Venmo'
```

*Note:* If you are using version 4.x.x of the Braintree iOS SDK in Xcode 12, you may see the warning `The iOS Simulator deployment target is set to 8.0, but the range of supported deployment target versions is 9.0 to 14.0.99`. This will not prevent your app from compiling. This is a [CocoaPods issue](https://github.com/CocoaPods/CocoaPods/issues/7314) with a known workaround.

### Carthage
Add `github "braintree/braintree_ios"` to your `Cartfile`, and [add the frameworks to your project](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

*Note:* Long term support for Carthage is not guaranteed. Please update to SPM, if possible. If there are concerns, please comment on [this Discussion thread](https://github.com/braintree/braintree_ios/discussions/705).

## Documentation

Start with [**'Hello, Client!'**](https://developer.paypal.com/braintree/docs/start/hello-client/ios/v5) for instructions on basic setup and usage.

Next, read the [**full documentation**](https://developer.paypal.com/braintree/docs/guides/payment-method-types-overview) for information about integrating with additional payment methods, such as PayPal and Venmo, as well as explore our pre-built [Drop-In UI offering](https://developer.paypal.com/braintree/docs/guides/drop-in/overview).


## Versions

This SDK abides by our Client SDK Deprecation Policy. For more information on the potential statuses of an SDK check our [developer docs](https://developer.paypal.com/braintree/docs/guides/client-sdk/deprecation-policy/ios/v5).

| Major version number | Status | Released | Deprecated | Unsupported |
| -------------------- | ------ | -------- | ---------- | ----------- |
| 5.x.x | Active | February 2021 | TBA | TBA |
| 4.x.x | Inactive | November 2015 | February 2022 | February 2023 |

Versions 4.9.6 and below use outdated SSL certificates and are unsupported.

## Demo

A demo app is included in the project. To run it you will need to do the following:
    1. Run `pod install`
    2. Resolve the Swift Package Manager packages if needed: `File` > `Packages` > `Resolve Package Versions` or by running `swift package resolve` in Terminal
    3. Open `Braintree.xcworkspace` in Xcode. 

Xcode 13+ is required to run the demo app.

## Contributing

We welcome PRs to this repo. See our [development doc](https://github.com/braintree/braintree_ios/blob/master/DEVELOPMENT.md).

## Feedback

The Braintree iOS SDK is in active development, we welcome your feedback!

Here are a few ways to get in touch:

* [GitHub Issues](https://github.com/braintree/braintree_ios/issues) - For generally applicable issues and feedback
* [Braintree Support](https://articles.braintreepayments.com/) / support@braintreepayments.com - for personal support at any phase of integration

## Help

* Read the headers
* [Read the Braintree docs](https://developer.paypal.com/braintree/docs/guides/client-sdk/setup/ios/v5)
* [Check out the reference docs](https://braintree.github.io/braintree_ios/)
* Find a bug? [Open an issue](https://github.com/braintree/braintree_ios/issues)
* Want to contribute? [Check out contributing guidelines](https://github.com/braintree/braintree_ios/blob/master/CONTRIBUTING.md) and [submit a pull request](https://help.github.com/articles/creating-a-pull-request).

### License

The Braintree iOS SDK is open source and available under the MIT license. See the [LICENSE](https://github.com/braintree/braintree_ios/blob/master/LICENSE) file for more info.
