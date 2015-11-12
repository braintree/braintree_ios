# Braintree iOS SDK 4.0 Migration Guide

We've made some big improvements to the Braintree iOS SDK in version 4.0.

Because the Braintree iOS SDK follows [Semantic Versioning](http://semver.org), version 4.0 contains API and architectural changes that require updates when upgrading from 3.x.

We believe this release will simplify your integration and provide more flexibility.

## The philosophy

- Allow merchants to integrate only the payment options they need
  - Decouple payment option components from core API components
  - Slim down the SDK size footprint
- Expose low-level operations to allow merchants to do more things
- Be more modern
  - Block-based APIs
  - Written in Obj-C, but audited to integrate well with Swift apps
- More integration options: CocoaPods, Carthage, static library, manual
- Support for [tokenization keys](https://developers.braintreepayments.com/guides/authorization/tokenization-key)

## Core changes

- The `Braintree` class has been replaced by `BTAPIClient`
  - Importing `Braintree.h` will no longer work! Instead, import the umbrella headers of the components you use:

| Component      | Header Import                      |
|----------------|------------------------------------|
| Core           | #import "BraintreeCore.h"          |
| Cards          | #import "BraintreeCard.h"          |
| PayPal         | #import "BraintreePayPal.h"        |
| Apple Pay      | #import "BraintreeApplePay.h"      |
| UI             | #import "BraintreeUI.h"            | 
| 3D Secure      | #import "Braintree3DSecure.h"      |
| Data Collector | #import "BraintreeDataCollector.h" |

- Each payment option (e.g. cards, PayPal) has its own *client* or *driver* object class that performs tokenization and returns payment method nonces:

| Payment option | Class name       |
|----------------|------------------|
| Cards          | [BTCardClient](https://github.com/braintree/braintree_ios/blob/master/BraintreeCard/Public/BTCardClient.h)             |
| PayPal         | [BTPayPalDriver](https://github.com/braintree/braintree_ios/blob/master/BraintreePayPal/Public/BTPayPalDriver.h)       |
| Apple Pay      | [BTApplePayClient](https://github.com/braintree/braintree_ios/blob/master/BraintreeApplePay/Public/BTApplePayClient.h) |

- The Braintree iOS SDK can be initialized with a tokenization key, which is a static Braintree API key that is specified at compile-time. Tokenization keys support a subset of the client token's capabilities, but they have the advantage of allowing you to start interacting with Braintree services without the overhead of a network call to generate a client token.
- `BTPaymentMethod` has been renamed to `BTPaymentMethodNonce`:
  - When tokenizing payment details, you will receive a `BTPaymentMethodNonce` object or a subclass of it, which contains a `nonce`
- `Braintree-Payments.h` and `BTPaymentProvider` have been removed in favor of independent payment options. Similarly, `BTPaymentMethodCreationDelegate` has been removed. Instead, use the new block-based API to get `BTPaymentMethodNonce` objects, `BTAppSwitchDelegate` for app switch lifecycle events, and `BTViewControllerPresentingDelegate` for view controller presentation.

## Credit and debit card changes

- `BTClientCardTokenizationRequest` has been replaced with `BTCard`
- `BTClientCardRequest`'s functionality has been squashed into `BTCard`

## UI-related changes

- `Braintree-Payments-UI.h` has been replaced with `BraintreeUI.h`
- `BTPaymentButton`
  - Uses a block-based API instead of a delegate to return payment method nonces
  - `paymentProviderTypes` has been replaced with the `enabledPaymentOptions` property

## Other payment options

- Coinbase is not available in the 4.0 version at this time. To join the Coinbase beta, contact [coinbase@braintreepayments.com](mailto:coinbase@braintreepayments.com).
- `Braintree-PayPal.h` has been replaced with `BraintreePayPal.h`

## Anti-fraud changes

- Data has been renamed to DataCollector. For example, if you have `pod 'Braintree/Data'` in your Podfile, rename it to `pod 'Braintree/DataCollector'`.

