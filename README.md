# Braintree v.zero SDK for iOS

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Welcome to Braintree's v.zero SDK for iOS. This library will help you accept card, PayPal, and Venmo payments in your iOS app.

The Braintree SDK requires Xcode 7, iOS SDK 8.0+, and a minimum iOS target of 7.0.

![Screenshot of v.zero](screenshot.png)

## Getting Started

** These instructions are for installing the 4.0 beta release **

We recommend using either [Cocoapods](https://github.com/CocoaPods/CocoaPods) or [Carthage](https://github.com/Carthage/Carthage) to integrate the Braintree SDK with your project.

### Cocoapods

To get started with a default installation, add `pod 'Braintree', :git => 'https://github.com/braintree/braintree_ios.git', :branch => '4.0-beta'` to your `Podfile` and run `pod install`. This includes everything you need to accept card, PayPal, and Venmo payments, and also includes our drop-in UI and payment button.

You can customize your integration by specifying additional components. For example, you can add Apple Pay support:

```
pod 'Braintree', :git => 'https://github.com/braintree/braintree_ios.git', :branch => '4.0-beta'
pod 'Braintree/Apple-Pay', :git => 'https://github.com/braintree/braintree_ios.git', :branch => '4.0-beta'
```

You can also strip down your integration to only support credit and debit cards:

```
pod 'Braintree/Card', :git => 'https://github.com/braintree/braintree_ios.git', :branch => '4.0-beta'
```

See our [`Podspec`](https://github.com/braintree/braintree_ios/blob/master/Braintree.podspec) for more information.

### Carthage

Add `github "braintree/braintree_ios" "4.0-beta"` to your `Cartfile`, and [add the frameworks to your project](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

### Static Library

We plan to offer a static library of the Braintree SDK.

### Manual Integration

Follow the [manual integration instructions](https://github.braintreeps.com/braintree/braintree-ios/blob/master/Docs/Manual%20Integration.md).

## Supporting iOS 9

iOS 9 introduces new security requirements and restrictions that can impact the behavior of the Braintree SDK.

### App Transport Security

If your app is compiled with iOS 9 SDK, it must comply with Apple's [App Transport Security](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/) policy.

Please whitelist the Braintree Gateway domain by adding the following to your application's plist:

```
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSExceptionDomains</key>
    <dict>
      <key>api.braintreegateway.com</key>
      <dict>
          <key>NSExceptionRequiresForwardSecrecy</key>
          <false/>
      </dict>
    </dict>
  </dict>
```

If your app uses PayPal, include the following under `NSExceptionDomains`:

```
  <key>www.paypalobjects.com</key>
    <dict>
      <key>NSExceptionRequiresForwardSecrecy</key>
      <false/>
  </dict>
```

If your app uses BraintreeFraud, also include the following under `NSExceptionDomains`:

```
  <key>kaptcha.com</key>
    <dict>
      <key>NSExceptionRequiresForwardSecrecy</key>
      <false/>
      <key>NSIncludesSubdomains</key>
      <true/>
      <key>NSTemporaryExceptionMinimumTLSVersion</key>
      <string>TLSv1.0</string>
  </dict>
```

We are actively working to update the SSL certificates of these servers so that your app will not require these exceptions in the near future.

### URL Query Scheme Whitelist

If your app is compiled with iOS 9 SDK and integrates payment options with an app-switch workflow, you must add URL schemes to the whitelist in your application's plist.

If your app supports payments from PayPal:
* `com.paypal.ppclient.touch.v1`
* `com.paypal.ppclient.touch.v2`

If your app supports payments from Venmo:
* `com.venmo.touch.v1`

For example, if your app supports both PayPal and Venmo, you could add the following:
```
  <key>LSApplicationQueriesSchemes</key>
  <array>
    <string>com.venmo.touch.v1</string>
    <string>com.paypal.ppclient.touch.v1</string>
    <string>com.paypal.ppclient.touch.v2</string>
  </array>
```

#### Bitcode

The Braintree SDK works with apps that have [bitcode](https://developer.apple.com/library/prerelease/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AppThinning/AppThinning.html#//apple_ref/doc/uid/TP40012582-CH35-SW3) enabled.

However, if your integration uses `BraintreeFraud` for fraud detection, it does not currently support having bitcode enabled. This will be fixed in an upcoming release.

## Documentation

Start with [**'Hello, Client!'**](https://developers.braintreepayments.com/ios/start/hello-client) for instructions on basic setup and usage.

Next, read the [**full documentation**](https://developers.braintreepayments.com/ios/sdk/client) for information about integration options, such as Drop-In UI, custom payment button, and credit card tokenization.

Finally, [**cocoadocs.org/docsets/Braintree**](http://cocoadocs.org/docsets/Braintree) hosts the complete, up-to-date API documentation generated straight from the header files.

## Demo

A demo app is included in project. To run it, run `pod install` and then open `Braintree.xcworkspace` in Xcode. See the [README](Demos/Braintree-Demo/README.md) for more details.

## Help

* [Read the headers](Braintree/Braintree.h)
* [Read the docs](https://developers.braintreepayments.com/ios/sdk/client)
* Find a bug? [Open an issue](https://github.com/braintree/braintree_ios/issues)
* Want to contribute? [Check out contributing guidelines](CONTRIBUTING.md) and [submit a pull request](https://help.github.com/articles/creating-a-pull-request).

## Feedback

Braintree v.zero is in active development. We appreciate the time you take to try it out and welcome your feedback!

Here are a few ways to get in touch:

* [GitHub Issues](https://github.com/braintree/braintree_ios/issues) - For generally applicable issues and feedback
* [Braintree Support](https://articles.braintreepayments.com/) / support@braintreepayments.com - for personal support at any phase of integration

### License

The Braintree v.zero SDK is open source and available under the MIT license. See the [LICENSE](LICENSE) file for more info.
