# Braintree iOS SDK

The iOS SDK provides developers with a collection of easy-to-use APIs for adding native payments to their iOS application. It has three components:

## Requirements

The Braintree iOS SDK and Venmo Touch require iOS 5.0.0 or higher. Currently, Venmo Touch is available for US customers only.

## Getting Started

The easiest way to get started with with <a href="http://cocoapods.org/">Cocoapods</a>.

```
# Add this line to your Podspec
pod 'Braintree', :git => 'https://github.com/braintree/braintree_ios.git'
```

For a quick-start tutorial, visit <a href="https://www.braintreepayments.com/docs/ios/guide/quickstart">our documentation site</a>.

## Components

* [Venmo Touch](https://www.braintreepayments.com/docs/ios/venmo_touch/overview), a one-tap purchasing network enabling your users to make in-app purchases without typing in their credit card details. 
* The [payment form](https://www.braintreepayments.com/docs/ios/payment_form/overview): A beautiful, polished credit card entry form complete with built-in validations, ready for you to drop into your app.
* [Encryption](https://www.braintreepayments.com/docs/ios/encryption/overview): Client-side encryption allowing you to encrypt credit card data before sending it to your servers and on to the Braintree gateway, making PCI compliance a breeze.

These components are designed to work together, but can be used independently of each other. For example, you could use Venmo Touch and client-side encryption without using the prebuilt payment form.

## Documentation

You can find a complete set of documentation about the iOS SDK on [Braintree's website](https://www.braintreepayments.com/docs/ios). You might want to specifically check out the articles on:

* [Adding a credit card form and Venmo Touch to your app](https://www.braintreepayments.com/docs/ios/guide/quickstart)
* [Adding Venmo Touch to an app that already accepts credit cards](https://www.braintreepayments.com/docs/ios/venmo_touch/tutorial)
* [Server-side integration with Venmo Touch](https://www.braintreepayments.com/docs/ruby/credit_cards/create_vt)
* [Venmo Touch Concepts](https://www.braintreepayments.com/docs/ios/venmo_touch/concepts)
* [Venmo Touch Style Guide](https://www.braintreepayments.com/docs/ios/venmo_touch/style_guide)

For detailed class and method reference see the Venmo Touch header files and Braintree header/implementation files, all of which are extensively commented.

## Getting Help

Tried integrating with VenmoTouch and still need help? Feel free to file a Github Issue or shoot us an email at <a href="mailto:support@braintreepayments.com">support@braintreepayments.com</a>.
