# Braintree iOS SDK 4.0 Migration Guide

We've made some big improvements to the Braintree iOS SDK in version 4.0.

Because the Braintree iOS SDK follows [Semantic Versioning](http://semver.org), version 4.0 contains API and architectural changes that require updates when upgrading from 3.x.

We believe this release will simplify your integration and provide more flexibility.

## Why upgrade to v4?

- Slimmer SDK size: integrate only the payment options you use
- Use [PayPal One Touch](https://developers.braintreepayments.com/guides/one-touch/paypal) to accept PayPal payments by switching to the PayPal app or to the mobile browser. If the app/browser has an active session, then login is not required.
  - One Touch provides a [Checkout flow](https://developers.braintreepayments.com/guides/paypal/checkout-with-paypal) for accepting one-time payments via PayPal
- More ways to integrate: Carthage, static library (coming soon)
- Block-based APIs
- Nullability annotation for improved Swift interop

## Minimum requirements: iOS 7, iOS SDK 9.0, Xcode 7

The Braintree iOS SDK requires Xcode 7+ and a base SDK of 9.0+. It supports devices running iOS 7 and above.

## Installation

We now support installation via [CocoaPods](https://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage), and [manual integration](https://github.com/braintree/braintree_ios/blob/master/Docs/Manual%20Integration.md). We will be adding support for static libraries very soon!

The [Getting Started](https://github.com/braintree/braintree_ios#getting-started) section of the README has more information.

## Setup and initialization

The setup and initialization of the SDK has changed slightly. The `Braintree` class has been replaced by `BTAPIClient`:

```objectivec
#import "BraintreeCore.h"

BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"<#client_token_or_tokenization_key#>"];
```

`BTAPIClient` can also be initialized with a [tokenization key](https://developers.braintreepayments.com/guides/authorization/tokenization-key).

### Configuring the return URL scheme

If your app accepts [payments via PayPal](https://developers.braintreepayments.com/guides/paypal/overview), then you must register a custom return URL scheme. If not, you can skip these steps:

1. [Register a URL type for your app in Xcode](https://developers.braintreepayments.com/start/hello-client/ios/v4#register-a-url-type)
2. Update your app delegate to [register this URL scheme with `BTAppSwitch`](https://developers.braintreepayments.com/start/hello-client/ios/v4#update-your-application-delegate)
3. Don't forget to update your application delegate to pass the URL in `application:openURL:sourceApplication:annotation:` and/or `application:openURL:options:` into `BTAppSwitch` (see link above)

## Accepting payments

Previously in 3.x, `BTPaymentProvider` was a centralized provider of `BTPaymentMethod` objects for each payment option. In 4.0, this has been re-architected so that each payment option has its own class responsible for tokenizing payment methods.

These classes are called *drivers* when they involve some UI interaction, or *clients* when they are headless:

| Payment option | Class                                                                                                                              |
|----------------|------------------------------------------------------------------------------------------------------------------------------------|
| Cards          | [BTCardClient](https://github.com/braintree/braintree_ios/blob/master/BraintreeCard/Public/BTCardClient.h)                         |
| PayPal         | [BTPayPalDriver](https://github.com/braintree/braintree_ios/blob/master/BraintreePayPal/Public/BTPayPalDriver.h)                   |
| Apple Pay      | [BTApplePayClient](https://github.com/braintree/braintree_ios/blob/master/BraintreeApplePay/Public/BTApplePayClient.h)             |
| 3D Secure      | [BTThreeDSecureDriver](https://github.com/braintree/braintree_ios/blob/master/BraintreeThreeDSecure/Public/BTThreeDSecureDriver.h) |

Payment option clients and drivers use block-based APIs to return `BTPaymentMethodNonce` instances that have a `nonce` property.

Drivers have a required `viewControllerPresentingDelegate` property, which should be set to your view controller, which is responsible for modally presenting and dismissing the view controllers required to finalize payments.

See each class's header file for more information.

## Other changes

### Tokenization keys

`BTAPIClient` can also be initialized with a [tokenization key](https://developers.braintreepayments.com/guides/authorization/tokenization-key), which is a static Braintree API key that is specified at compile-time. Tokenization keys support a subset of the client token's capabilities, but they have the advantage of allowing you to start interacting with Braintree services without the overhead of a network call to generate a client token.

### Project reorganization

The components of the Braintree iOS SDK have been renamed, and each component has an umbrella header that imports the publicly available classes for that component:

| Component      | Header Import                      |
|----------------|------------------------------------|
| Core           | #import "BraintreeCore.h"          |
| Cards          | #import "BraintreeCard.h"          |
| PayPal         | #import "BraintreePayPal.h"        |
| Apple Pay      | #import "BraintreeApplePay.h"      |
| UI             | #import "BraintreeUI.h"            |
| 3D Secure      | #import "Braintree3DSecure.h"      |
| Data Collector | #import "BraintreeDataCollector.h" |

### Where's Venmo?

We are waiting for the upcoming release of Pay with Venmo before we offer Venmo as a component on v4.

### Credit and debit card

- `BTClientCardTokenizationRequest` has been replaced with `BTCard`
- `BTClientCardRequest`'s functionality has been squashed into `BTCard`

### PayPal

- Use [`BTPayPalDriver`](https://github.com/braintree/braintree_ios/blob/master/BraintreePayPal/Public/BTPayPalDriver.h) to initiate PayPal payment flows.
- `Braintree-PayPal.h` has been replaced with `BraintreePayPal.h`

### UI

- `Braintree-Payments-UI.h` has been replaced with `BraintreeUI.h`
- `BTPaymentButton`
  - Uses a block-based API instead of a delegate to return payment method nonces
  - `paymentProviderTypes` has been replaced with the `enabledPaymentOptions` property

### Other payment options

- Coinbase is not available in the 4.0 version at this time. To join the Coinbase beta, contact [coinbase@braintreepayments.com](mailto:coinbase@braintreepayments.com).

### Anti-fraud changes

- Data has been renamed to DataCollector. For example, if you have `pod 'Braintree/Data'` in your Podfile, rename it to `pod 'Braintree/DataCollector'`.

