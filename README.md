# Braintree iOS SDK

[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Braintree.svg?style=flat)](https://cocoapods.org/pods/Braintree)
[![Swift Package Manager compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

![GitHub Actions Tests](https://github.com/braintree/braintree_ios/workflows/Tests/badge.svg)

Welcome to Braintree's iOS SDK. This library will help you accept card and alternative payments in your iOS app.

## 📣 Announcements

- **Upgrade your integration to continue accepting Braintree payments** 📣 The SSL certificates for current iOS SDK versions (v5 and v6) are set to expire by June 31, 2025. Upgrade to v5.26.0+ and v6.17.0+, respectively, to continue using the Braintree SDK. [Click here for more details](https://github.com/braintree/braintree_ios/issues/1277)

- v6 is the latest major version of Braintree iOS. To update from v5, see the [v6 migration guide](https://github.com/braintree/braintree_ios/blob/main/V6_MIGRATION.md). If you have not yet migrated to v5, see the [v5 migration guide](https://github.com/braintree/braintree_ios/blob/5.x/V5_MIGRATION.md)

**The Braintree iOS SDK permits a deployment target of iOS 14.0 or higher**. It requires Xcode 15.0+ and Swift 5.9+.

## Supported Payment Methods

- [Credit Cards](https://developer.paypal.com/braintree/docs/guides/credit-cards/overview)
- [PayPal](https://developer.paypal.com/braintree/docs/guides/paypal/overview)
- [Pay with Venmo](https://developer.paypal.com/braintree/docs/guides/venmo/overview)
- [Apple Pay](https://developer.paypal.com/braintree/docs/guides/apple-pay/overview)
- [ThreeDSecure](https://developer.paypal.com/braintree/docs/guides/3d-secure/overview)
- [Local Payment Methods](https://developer.paypal.com/braintree/articles/guides/payment-methods/local-payment-methods)

## Installation

We recommend using [Swift Package Manager](https://swift.org/package-manager/), [CocoaPods](https://github.com/CocoaPods/CocoaPods), or [Carthage](https://github.com/Carthage/Carthage) to integrate the Braintree SDK with your project.

### Swift Package Manager

To add the `Braintree` package to your Xcode project, select _File > Swift Packages > Add Package Dependency_ and enter `https://github.com/braintree/braintree_ios` as the repository URL. Tick the checkboxes for the specific Braintree libraries you wish to include.

If you look at your app target, you will see that the Braintree libraries you chose are automatically linked as a frameworks to your app (see _General > Frameworks, Libraries, and Embedded Content_).

*`BraintreePayPal` and `BraintreeLocalPayment` also require the inclusion of the `BraintreeDataCollector` module.*

In your app's source code files, use the following import syntax to include Braintree's libraries:
```
import BraintreeCore
import BraintreeCard
import BraintreeApplePay
import BraintreePayPal
```

### CocoaPods
```
# Includes Cards and PayPal
pod 'Braintree'

# Optionally include additional Pods
pod 'Braintree/DataCollector'
pod 'Braintree/Venmo'
```

### Carthage
Braintree 6.0.0+ requires Carthage 0.38.0+ and the `--use-xcframeworks` option when running `carthage update`.

Add `github "braintree/braintree_ios"` to your `Cartfile`, and [add the frameworks to your project](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

*Note:* Long term support for Carthage is not guaranteed. Please update to SPM, if possible. If there are concerns, please comment on [this Discussion thread](https://github.com/braintree/braintree_ios/discussions/705).

## Documentation

Start with [**'Hello, Client!'**](https://developer.paypal.com/braintree/docs/start/hello-client/ios/v6) for instructions on basic setup and usage.

Next, read the [**full documentation**](https://developer.paypal.com/braintree/docs/guides/payment-method-types-overview) for information about integrating with additional payment methods, such as PayPal and Venmo, as well as explore our pre-built [Drop-In UI offering](https://developer.paypal.com/braintree/docs/guides/drop-in/overview).

## Upgrade Your SDK Version

If you're looking to update to a newer version of our SDK, please see our recommended approach below.

### Using Swift Package Manager

 To update using Swift Package Manager, select _File→ Packages → Update to Latest Package Versions_.

### Using Cocoapods 

You can either update all pods listed within your Podfile using `pod update` or specific pods as needed using `pod update PODNAME`. For additional details, see the [Cocoapods guidelines](https://guides.cocoapods.org/using/pod-install-vs-update.html).

### Using Carthage

To update to the latest versions of each framework, simply run the `carthage update` command. For more details, check out the [Carthage guidelines](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#version-requirement).

## Versions

This SDK abides by our Client SDK Deprecation Policy. For more information on the potential statuses of an SDK check our [developer docs](https://developer.paypal.com/braintree/docs/guides/client-sdk/deprecation-policy/ios/v5).

| Major version number | Status | Released | Deprecated | Unsupported |
| -------------------- | ------ | -------- | ---------- | ----------- |
| 6.x.x | Active | June 2023 | TBA | TBA |
| 5.x.x | Inactive | February 2021 | June 2024 | June 2025 |
| 4.x.x | Unsupported | November 2015 | February 2022 | February 2023 |

## Demo

1. Our Xcode project uses SwiftLint. To ensure you have it installed see [DEVELOPMENT.md](https://github.com/braintree/braintree_ios/blob/main/DEVELOPMENT.md#swiftlint)
1. Run `pod install`
1. Resolve the Swift Package Manager packages if needed: `File` > `Packages` > `Resolve Package Versions` or by running `swift package resolve` in Terminal
1. Open `Braintree.xcworkspace` in Xcode
1. Select the `Demo` scheme, and then run

Xcode 15.0+ is required to run the demo app.

## Contributing

We welcome PRs to this repo. See our [development doc](https://github.com/braintree/braintree_ios/blob/main/DEVELOPMENT.md).

## Feedback

The Braintree iOS SDK is in active development, we welcome your feedback!

Here are a few ways to get in touch:

* [GitHub Issues](https://github.com/braintree/braintree_ios/issues) - For generally applicable issues and feedback
* [Braintree Support](https://articles.braintreepayments.com/) / [Braintree Help Form](https://developer.paypal.com/braintree/help) - for personal support at any phase of integration

## Help

* [Read the Braintree docs](https://developer.paypal.com/braintree/docs/guides/client-sdk/setup/ios/v5)
* [Check out the reference docs](https://braintree.github.io/braintree_ios/)
* Find a bug? [Open an issue](https://github.com/braintree/braintree_ios/issues)
* Want to contribute? [Check out contributing guidelines](https://github.com/braintree/braintree_ios/blob/main/CONTRIBUTING.md) and [submit a pull request](https://help.github.com/articles/creating-a-pull-request).

### License

The Braintree iOS SDK is open source and available under the MIT license. See the [LICENSE](https://github.com/braintree/braintree_ios/blob/main/LICENSE) file for more info.
