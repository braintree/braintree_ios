# Braintree v.zero SDK for iOS

Welcome to Braintree's v.zero SDK for iOS. This CocoaPod will help you accept card, PayPal, and Venmo payments in your iOS app.

![Screenshot of v.zero](screenshot.png)

## Documentation

Start with [**'Hello, Client!'**](https://developers.braintreepayments.com/ios/start/hello-client) for instructions on basic setup and usage.

Next, read the [**full documentation**](https://developers.braintreepayments.com/ios/sdk/client) for information about integration options, such as Drop-In UI, custom payment button, and credit card tokenization.

Finally, [**cocoadocs.org/docsets/Braintree**](http://cocoadocs.org/docsets/Braintree) hosts the complete, up-to-date API documentation generated straight from the header files.

## Demo

A demo app is included in project. To run it, run `pod install` and then open `Braintree.xcworkspace` in Xcode. See the [README](Demos/Braintree-Demo/README.md) for more details.

### Special note on preprocessor macros

Apple Pay is a build option. To include Apple Pay support in your build, use the `Apple-Pay` subspec in your Podfile:

```
pod "Braintree"
pod "Braintree/Apple-Pay"
```

Then ensure `BT_ENABLE_APPLE_PAY=1` is present in your target's "Preprocessor Macros" settings.
By default, this should happen automatically if you have a Preprocessor Macro entry for `$(inherited)`.

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
