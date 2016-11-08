# Braintree iOS SDK

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Travis CI build status](https://travis-ci.org/braintree/braintree_ios.svg?branch=master)](https://travis-ci.org/braintree/braintree_ios)

Welcome to Braintree's iOS SDK. This library will help you accept card and alternative payments in your iOS app.

**The Braintree iOS SDK requires Xcode 7+ and a Base SDK of iOS 9+**. It permits a Deployment Target of iOS 7.0 or higher.

## Getting Started

The current major version is 4.x. If you are upgrading from version 3.x, take a look at our [Braintree iOS 3.x to 4.x Migration Guide](Docs/Braintree-4.0-Migration-Guide.md).

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

Please follow the [static library integration instructions](Docs/Braintree-Static-Integration-Guide.md).

### Manual Integration

For v3 integrations, please follow the [v3 manual integration instructions](https://github.com/braintree/braintree_ios/blob/3.x/Docs/Manual%20Integration.md).

Note that for apps targeting iOS 8+, you may add `Braintree.xcodeproj` to your Xcode workspace and add the frameworks to the app target **Embedded Binaries** section.

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

Next, read the [**full documentation**](https://developers.braintreepayments.com/ios/sdk/client) for information about integration options, such as Drop-In UI, PayPal, and credit card tokenization.

Finally, [**cocoadocs.org/docsets/Braintree**](http://cocoadocs.org/docsets/Braintree) hosts the complete, up-to-date API documentation generated straight from the header files.

## Demo

A demo app is included in project. To run it, run `pod install` and then open `Braintree.xcworkspace` in Xcode.

## Help

* Read the headers
* [Read the docs](https://developers.braintreepayments.com/ios/sdk/client)
* Find a bug? [Open an issue](https://github.com/braintree/braintree_ios/issues)
* Want to contribute? [Check out contributing guidelines](CONTRIBUTING.md) and [submit a pull request](https://help.github.com/articles/creating-a-pull-request).

## Feedback

The Braintree iOS SDK is in active development, we welcome your feedback!

Here are a few ways to get in touch:

* [GitHub Issues](https://github.com/braintree/braintree_ios/issues) - For generally applicable issues and feedback
* [Braintree Support](https://articles.braintreepayments.com/) / support@braintreepayments.com - for personal support at any phase of integration

## Releases

Subscribe to our [Google Group](https://groups.google.com/forum/#!forum/braintree-sdk-announce) to
be notified when SDK releases go out.

### License

The Braintree iOS SDK is open source and available under the MIT license. See the [LICENSE](LICENSE) file for more info.
