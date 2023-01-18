# Braintree iOS v6 Migration Guide

See the [CHANGELOG](/CHANGELOG.md) for a complete list of changes. This migration guide outlines the basics for updating your client integration from v5 to v6.

_Documentation for v6 will be published to https://developer.paypal.com/braintree/docs once it is available for general release._

## Table of Contents

1. [Supported Versions](#supported-versions)
2. [Carthage](#carthage)
3. [Braintree Core](#braintree-core)
4. [Venmo](#venmo)
5. [PayPal](#paypal)
6. [PayPal Native Checkout](#paypal-native-checkout)
7. [Data Collector](#data-collector)
8. [Union Pay](#union-pay)

## Supported Versions

v6 supports a minimum deployment target of iOS 14+. It requires the use of Xcode 14+ and Swift version 5.7+. If your application contains Objective-C code, the `Enable Modules` build setting must be set to `YES`.

## Carthage

v6 requires Carthage v0.38.0+, which adds support for xcframework binary dependencies.

```
carthage update --use-xcframeworks
```

## Braintree Core
`BTAppContextSwitchDriver` has been renamed to `BTAppContextSwitchClient`

`BTViewControllerPresentingDelegate` protocol functions `paymentDriver` are renamed to `paymentClient` now takes in the `client` parameter instead of `driver`:
```
public func paymentClient(_ client: Any, requestsDismissalOf viewController: UIViewController) {
    // implementation here
}

public func paymentClient(_ client: Any, requestsPresentationOf viewController: UIViewController) {
    // implementation here
}
```

## Venmo
`BTVenmoDriver` has been renamed to `BTVenmoClient`

`BTVenmoRequest` must now be initialized with a `paymentMethodUsage`. 

The possible values for `BTVenmoPaymentMethodUsage` include:
* `.multiUse` - the Venmo payment will be authorized for future payments and can be vaulted.
* `.singleUse` - the Venmo payment will be authorized for a one-time payment and cannot be vaulted.

```
let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
venmoRequest.profileID = "my-profile-id"
venmoRequest.vault = true

venmoClient.tokenizeVenmoAccount(with: venmoRequest) { venmoAccountNonce, error in
    guard let venmoAccountNonce = venmoAccountNonce else {
        // handle error
    }
    // send nonce to server
}
```

## PayPal
`BTPayPalDriver` has been renamed to `BTPayPalClient`

Removed `BTPayPalDriver.requestOneTimePayment` and `BTPayPalDriver.requestBillingAgreement` in favor of `BTPayPalClient.tokenizePayPalAccount`:
```
let payPalClient = BTPayPalClient(apiClient: <MY_BTAPICLIENT>)
let request = BTPayPalCheckoutRequest(amount: "1")

payPalClient.tokenize(request) { payPalAccountNonce, error in
    guard let payPalAccountNonce = payPalAccountNonce else {
        // handle error
    }
    // send nonce to server
}
```

`BTPayPalClient.tokenizePayPalAccount(with: BTPayPalRequest, completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void)` has been replaced with two methods: `tokenize(_ request: BTPayPalVaultRequest, completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void)` and `tokenize(_ request: BTPayPalCheckoutRequest, completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void)`:

```
// BTPayPalCheckoutRequest
let request = BTPayPalCheckoutRequest(amount: "1")
payPalClient.tokenize(request) { payPalAccountNonce, error in 
    // handle response
}

// BTPayPalVaultRequest
let request = BTPayPalVaultRequest()
payPalClient.tokenize(request) { payPalAccountNonce, error in 
    // handle response
}
```

## PayPal Native Checkout
`BTPayPalNativeCheckoutClient.tokenizePayPalAccount(with: BTPayPalNativeRequest, completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void)` has been replaced with two methods: `tokenize(_ request: BTPayPalNativeCheckoutRequest, completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void)` and `tokenize(_ request: BTPayPalNativeVaultRequest, completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void)`:

```
// BTPayPalNativeCheckoutRequest
let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: <MY_BTAPICLIENT>)
let request = BTPayPalNativeCheckoutRequest(amount: "1")
payPalNativeCheckoutClient.tokenize(request) { payPalNativeCheckoutAccountNonce, error in 
    // handle response
}

// BTPayPalNativeVaultRequest
let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: <MY_BTAPICLIENT>)
let request = BTPayPalNativeVaultRequest()
payPalNativeCheckoutClient.tokenize(request) { payPalNativeCheckoutAccountNonce, error in 
    // handle response
}
```

## Data Collector
Note: Kount is no longer supported through the SDK in this version. Kount will continue to be supported in v5 of the SDK.

`PayPalDataCollector` module has been removed. All data collection for payment flows will use the `BraintreeDataCollector` module.

For merchants collecting device data for PayPal and Local Payment methods will now need to replace the `PayPalDataCollector` module with the `BraintreeDataCollector` module in their integration.

The new integration for collecting device data will look like the following:
```
let dataCollector = BTDataCollector(apiClient: <MY_BTAPICLIENT>)

dataCollector.collectDeviceData { deviceData, _ in
    guard let deviceData = deviceData else {
        // handle error
    }
    // Send deviceData to your server
}
```

## Union Pay
The `BraintreeUnionPay` module, and all containing classes, was removed in v6. UnionPay cards can now be processed as regular cards, through the `BraintreeCard` module. You no longer need to manage card enrollment via SMS authorization. 

Now, you can tokenize just with the card details:

```
let braintreeClient = BTAPIClient(authorization: "<CLIENT_AUTHORIZATION>")!
let cardClient = BTCardClient(apiClient: braintreeClient)

let card = BTCard()
card.number = "4111111111111111"
card.expirationMonth = "12"
card.expirationYear = "2025"

cardClient.tokenizeCard(card) { (tokenizedCard, error) in
    // Communicate the tokenizedCard.nonce to your server, or handle error
}
```
