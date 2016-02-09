# Braintree v.zero SDK for iOS

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Travis CI build status](https://travis-ci.org/braintree/braintree_ios.svg?branch=master)](https://travis-ci.org/braintree/braintree_ios)

Welcome to Braintree's v.zero SDK for iOS. This library will help you accept card and PayPal payments in your iOS app.

**The Braintree iOS SDK requires Xcode 7+ and a Base SDK of iOS 9+**. It permits a Deployment Target of iOS 7.0 or higher.

![Screenshot of v.zero](screenshot.png)

## Getting Started

The current major version is 4.x. If you are upgrading from version 3.x, take a look at our [Braintree iOS 3.x to 4.x Migration Guide](Docs/Braintree-4.0-Migration-Guide.md).

If you're looking to integrate version 4 and you need to accept payments with Venmo, please contact [Braintree Support](mailto:support@braintreepayments.com) about joining the beta program for Pay with Venmo. If you are using Version 3 of the iOS SDK, it fully supports accepting payments via Venmo One Touch.

We recommend using either [CocoaPods](https://github.com/CocoaPods/CocoaPods) or [Carthage](https://github.com/Carthage/Carthage) to integrate the Braintree SDK with your project.

### CocoaPods

Add to your `Podfile`:
```
pod 'Braintree'
```
Then run `pod install`. This includes everything you need to accept card and PayPal payments. It also includes our Drop-in UI and payment button.

Customize your integration by specifying additional components. For example, add Apple Pay support:
```
pod 'Braintree'
pod 'Braintree/Apple-Pay'
```

You can also strip down your integration to only support credit and debit cards:
```
pod 'Braintree/Card'
```

See our [`Podspec`](Braintree.podspec) for more information.

Although we recommend upgrading to the latest version of our SDK, you can choose to remain on the 3.x version, e.g.
```
pod 'Braintree', '~> 3.9'
```

### Carthage

Add `github "braintree/braintree_ios"` to your `Cartfile`, and [add the frameworks to your project](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

### Static Library

Coming soon: we will be offering a static library of the Braintree SDK.

### Manual Integration

For v3 integrations, please follow the [v3 manual integration instructions](https://github.com/braintree/braintree_ios/blob/3.x/Docs/Manual%20Integration.md).

Complete v4 manual integration instructions are still in-progress. Note that for apps targeting iOS 8+, you may add `Braintree.xcodeproj` to your Xcode workspace and add the frameworks to the app target **Embedded Binaries** section.

## Supporting iOS 9

Support for iOS 9 requires a few configuration changes with your Xcode project, detailed below.

### App Transport Security

iOS 9 introduces new security requirements and restrictions. If your app is compiled with iOS 9 SDK, it must comply with Apple's [App Transport Security](https://developer.apple.com/library/ios/technotes/App-Transport-Security-Technote/) policy.

The Braintree Gateway domain complies with this policy.

3D Secure uses third party domains, which may need to be whitelisted for ATS, as part of the authentication process.

### URL Query Scheme Whitelist

If your app is compiled with iOS 9 SDK and integrates payment options with an app-switch workflow, you must add URL schemes to the whitelist in your application's plist.

If your app supports payments from PayPal:
* `com.paypal.ppclient.touch.v1`
* `com.paypal.ppclient.touch.v2`

If your app supports payments from Venmo:
* `com.venmo.touch.v2`

For example, if your app supports PayPal, you could add the following:
```
  <key>LSApplicationQueriesSchemes</key>
  <array>
    <string>com.paypal.ppclient.touch.v1</string>
    <string>com.paypal.ppclient.touch.v2</string>
  </array>
```

There is a new `UIApplicationDelegate` method that you may implement on iOS 9:
```
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
```
Implementing this method is optional. If you do not implement it, the deprecated equivalent will still be called; otherwise, it will not.

In either case, you still need to implement the deprecated equivalent in order to support iOS 8 or earlier:
```
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
```

#### Bitcode

The Braintree SDK works with apps that have [bitcode](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AppThinning/AppThinning.html#//apple_ref/doc/uid/TP40012582-CH35-SW3) enabled.

## Documentation

Start with [**'Hello, Client!'**](https://developers.braintreepayments.com/ios/start/hello-client) for instructions on basic setup and usage.

Next, read the [**full documentation**](https://developers.braintreepayments.com/ios/sdk/client) for information about integration options, such as Drop-In UI, custom payment button, and credit card tokenization.

Finally, [**cocoadocs.org/docsets/Braintree**](http://cocoadocs.org/docsets/Braintree) hosts the complete, up-to-date API documentation generated straight from the header files.

## Demo

A demo app is included in project. To run it, run `pod install` and then open `Braintree.xcworkspace` in Xcode.

## Help

* Read the headers
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

This SDK includes code from a number of other open source releases, including the [PayPal iOS SDK](https://github.com/paypal/PayPal-iOS-SDK), [card.io](https://github.com/card-io) and AgileBit's [1Password App Extension](https://github.com/AgileBits/onepassword-app-extension). Please refer to the [PayPal iOS SDK acknowlegements](https://github.com/paypal/PayPal-iOS-SDK/blob/master/acknowledgments.md), as well as the [acknowlegements file generated by CocoaPods](https://github.com/CocoaPods/CocoaPods/wiki/Acknowledgements), for a complete listing of open source contributions that helped us create Braintree iOS.
